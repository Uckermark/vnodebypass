#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <spawn.h>
#include <unistd.h>
#include <rootless.h>


int main(int argc, char *argv[], char *envp[]) {
    @autoreleasepool {

        BOOL isRemoving = [NSProcessInfo.processInfo.processName containsString:@"prerm"];
        BOOL isUpgrading = strstr(argv[1], "upgrade");

        if (isRemoving || isUpgrading) {
            NSArray *fileList = [[NSString stringWithContentsOfFile:ROOT_PATH_NS(@"/var/lib/dpkg/info/kr.xsf1re.vnodebypass.list") encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
            NSInteger appPathIndex = [fileList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [obj hasSuffix:@".app"];
            }];

            if (appPathIndex != NSNotFound) {
                pid_t pid;
                const char *args[] = {ROOT_PATH("/usr/bin/uicache"), "-u", [fileList[appPathIndex] UTF8String], NULL};
                posix_spawn(&pid, args[0], NULL, NULL, (char *const *)args, envp);
                int status;
                waitpid(pid, &status, 0);
            } else {
                printf("Could not find vnodebypass.app, skipping uicache\n");
            }

            if (isRemoving) return 0;
        }

        NSString *randomName = [[NSUUID UUID].UUIDString componentsSeparatedByString:@"-"].firstObject;

        NSMutableDictionary *appInfo = [NSMutableDictionary dictionaryWithContentsOfFile:ROOT_PATH_NS(@"/Applications/vnodebypass.app/Info.plist")];
        appInfo[@"CFBundleExecutable"] = randomName;
        [appInfo writeToFile:ROOT_PATH_NS(@"/Applications/vnodebypass.app/Info.plist") atomically:YES];

        NSArray *renames = @[
            @[ ROOT_PATH_NS(@"/usr/bin/vnodebypass"), ROOT_PATH_NS(@"/usr/bin/%@") ],
            @[ ROOT_PATH_NS(@"/Applications/vnodebypass.app/vnodebypass"), ROOT_PATH_NS(@"/Applications/vnodebypass.app/%@") ],
            @[ ROOT_PATH_NS(@"/Applications/vnodebypass.app"), ROOT_PATH_NS(@"/Applications/%@.app") ],
            @[ ROOT_PATH_NS(@"/usr/share/vnodebypass"), ROOT_PATH_NS(@"/usr/share/%@") ]
        ];

        for (NSArray *rename in renames) {
            NSString *oldPath = rename[0];
            NSString *newPath = [NSString stringWithFormat:rename[1], randomName];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
            if (error) {
                printf("Failed to rename %s: %s\n", oldPath.UTF8String,
                error.localizedDescription.UTF8String);
                return 1;
            }
        }

        NSString *dpkgInfo = [NSString stringWithContentsOfFile:ROOT_PATH_NS(@"/var/lib/dpkg/info/kr.xsf1re.vnodebypass.list") encoding:NSUTF8StringEncoding error:nil];
        dpkgInfo = [dpkgInfo stringByReplacingOccurrencesOfString:@"vnodebypass" withString:randomName];
        [dpkgInfo writeToFile:ROOT_PATH_NS(@"/var/lib/dpkg/info/kr.xsf1re.vnodebypass.list") atomically:YES encoding:NSUTF8StringEncoding error:nil];

        pid_t pid;
        const char *args[] = {ROOT_PATH("/usr/bin/uicache"), "-p", [[NSString stringWithFormat:ROOT_PATH_NS(@"/Applications/%@.app"), randomName] UTF8String], NULL};
        posix_spawn(&pid, args[0], NULL, NULL, (char *const *)args, envp);
        int status;
        waitpid(pid, &status, 0);
        return 0;
    }
}
