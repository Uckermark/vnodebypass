#include "vnode.h"
#include "SVC_Caller.h"
#include "libdimentio.h"
#include "kernel.h"
#include <rootless.h>

const char *vnodeMemPath;
NSMutableArray *hidePathList = nil;
NSArray *recHidePathList = nil;
BOOL extensiveMode = NO;

__attribute__((constructor)) void initVnodeMemPath() {
  vnodeMemPath = [NSString stringWithFormat:ROOT_PATH_NS(@"/tmp/%@.txt"), NSProcessInfo.processInfo.processName].UTF8String;
}

BOOL addAllFilePathsInDirectory(NSString * directoryPath) {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
  if (!hidePathList) {
    NSLog(@"[vnbp] Failed to load hidePathList.plist");
    return NO;
  }
  for (NSString *fileName in contents) {
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    BOOL isDir;
    if (filePath && [fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
      if (isDir) {
        [hidePathList addObject:filePath];
        addAllFilePathsInDirectory(filePath);
      } else if(![hidePathList containsObject:filePath]){
        [hidePathList addObject:filePath];
        NSLog(@"[vnbp] added %@", filePath);
      }
    }
  }
  return YES;
}

void initRecPath() {
  recHidePathList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS(@"/usr/share/%@/recHidePathList.plist"), NSProcessInfo.processInfo.processName]];
  for (id path in recHidePathList) {
    if (![path isKindOfClass:[NSString class]]) goto exit;
    if(!addAllFilePathsInDirectory(path)) goto exit;
  }
  return;
exit:
  printf("recHidePathList.plist is broken, please reinstall vnodebypass!\n");
  exit(1);
}

void setExtensive(BOOL state) {
  extensiveMode = state;
}

void initPath() {
  hidePathList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS(@"/usr/share/%@/hidePathList.plist"), NSProcessInfo.processInfo.processName]];
  if (hidePathList == nil) goto exit;
  for (id path in hidePathList) {
    if (![path isKindOfClass:[NSString class]]) goto exit;
    NSString *pathStr = (NSString *)path;
    NSLog(@"[vnbp] %@", ROOT_PATH_NS(pathStr));
    if([(NSString *)path isEqualToString:@"START-EXTENSIVE"] && !extensiveMode) {
        NSUInteger startIndex = [hidePathList indexOfObject:path];
        NSUInteger count = [hidePathList count] - startIndex;
        NSRange range = NSMakeRange(startIndex, count);
        [hidePathList removeObjectsInRange:range];
        break;
    }
  }
  if(extensiveMode) initRecPath();
  return;
exit:
  printf("hidePathList.plist is broken, please reinstall vnodebypass!\n");
  exit(1);
}

void saveVnode() {
  if (access(vnodeMemPath, F_OK) == 0) {
    printf("Already exist /tmp/vnodeMem.txt, Please vnode recovery first!\n");
    return;
  }

  initPath();
  if (init_kernel() == 1) {
    printf("Failed init_kernel\n");
    return;
  }
  find_task(getpid(), &our_task);
  if (!this_proc) return;
  printf("this_proc: " KADDR_FMT "\n", this_proc);

  FILE *fp = fopen(vnodeMemPath, "w");

  int hideCount = (int)[hidePathList count];
  uint64_t vnodeArray[hideCount];

  for (int i = 0; i < hideCount; i++) {
    const char *hidePath = ROOT_PATH([[hidePathList objectAtIndex:i] UTF8String]);
    int file_index = open(hidePath, O_RDONLY);

    if (file_index == -1) continue;

    vnodeArray[i] = get_vnode_with_file_index(file_index, this_proc);
    printf("hidePath: %s, vnode[%d]: 0x%" PRIX64 "\n", hidePath, i, vnodeArray[i]);
    printf("vnode_usecount: 0x%" PRIX32 ", vnode_iocount: 0x%" PRIX32 "\n",
           kernel_read32(vnodeArray[i] + off_vnode_usecount),
           kernel_read32(vnodeArray[i] + off_vnode_iocount));
    fprintf(fp, "0x%" PRIX64 "\n", vnodeArray[i]);
    close(file_index);
  }
  fclose(fp);
  if (tfp0) mach_port_deallocate(mach_task_self(), tfp0);
  printf("Saved vnode to /tmp/vnodeMem.txt\nMake sure vnode recovery to prevent kernel panic!\n");
}

void hideVnode() {
  if (init_kernel() == 1) {
    printf("Failed init_kernel\n");
    return;
  }
  if (access(vnodeMemPath, F_OK) == 0) {
    FILE *fp = fopen(vnodeMemPath, "r");
    uint64_t savedVnode;
    int i = 0;
    while (!feof(fp)) {
      if (fscanf(fp, "0x%" PRIX64 "\n", &savedVnode) == 1) {
        printf("Saved vnode[%d] = 0x%" PRIX64 "\n", i, savedVnode);
        hide_path(savedVnode);
      }
      i++;
    }
  }
  if (tfp0) mach_port_deallocate(mach_task_self(), tfp0);
  printf("Hide file!\n");
}

void revertVnode() {
  if (init_kernel() == 1) {
    printf("Failed init_kernel\n");
    return;
  }
  if (access(vnodeMemPath, F_OK) == 0) {
    FILE *fp = fopen(vnodeMemPath, "r");
    uint64_t savedVnode;
    int i = 0;
    while (!feof(fp)) {
      if (fscanf(fp, "0x%" PRIX64 "\n", &savedVnode) == 1) {
        printf("Saved vnode[%d] = 0x%" PRIX64 "\n", i, savedVnode);
        show_path(savedVnode);
      }
      i++;
    }
  }
  if (tfp0) mach_port_deallocate(mach_task_self(), tfp0);
  printf("Show file!\n");
}

void recoveryVnode() {
  if (init_kernel() == 1) {
    printf("Failed init_kernel\n");
    return;
  }
  if (access(vnodeMemPath, F_OK) == 0) {
    FILE *fp = fopen(vnodeMemPath, "r");
    uint64_t savedVnode;
    int i = 0;
    while (!feof(fp)) {
      if (fscanf(fp, "0x%" PRIX64 "\n", &savedVnode) == 1) {
        kernel_write32(savedVnode + off_vnode_iocount,
                       kernel_read32(savedVnode + off_vnode_iocount) - 1);
        kernel_write32(savedVnode + off_vnode_usecount,
                       kernel_read32(savedVnode + off_vnode_usecount) - 1);
        printf("Saved vnode[%d] = 0x%" PRIX64 "\n", i, savedVnode);
        printf("vnode_usecount: 0x%" PRIX32 ", vnode_iocount: 0x%" PRIX32 "\n",
               kernel_read32(savedVnode + off_vnode_usecount),
               kernel_read32(savedVnode + off_vnode_iocount));
      }
      i++;
    }
    remove(vnodeMemPath);
  }
  if (tfp0) mach_port_deallocate(mach_task_self(), tfp0);
  printf("Recovered vnode! No more kernel panic when you shutdown.\n");
}

void checkFile() {
  initPath();
  int hideCount = (int)[hidePathList count];
  for (int i = 0; i < hideCount; i++) {
    const char *hidePath = ROOT_PATH([[hidePathList objectAtIndex:i] UTF8String]);
    int ret = 0;
    ret = SVC_Access(hidePath);
    printf("hidePath: %s, errno: %d\n", hidePath, ret);
  }
  printf("Done check file!\n");
}
