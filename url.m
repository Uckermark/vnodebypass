#import <Foundation/Foundation.h>
#include "shared/Constants.h"

void removeCustomURLSchemeFromApps() {
    NSArray<NSURL *> *urls = getAppUrls();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSURL *url in urls) {
        if (![url.pathExtension isEqualToString:@"app"]) {
            continue;
        }
        NSURL *infoPlistURL = [url URLByAppendingPathComponent:@"Info.plist"];
        if ([fileManager fileExistsAtPath:infoPlistURL.path]) {
            NSLog(@"[vnbp] Found Info.plist %@", infoPlistURL);
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:infoPlistURL.absoluteString];
            if ([infoDict objectForKey:@"CFBundleURLTypes"]) {
                NSError *error;
                NSError *removeError;
                NSString *path = [NSString stringWithFormat:@"%@", infoPlistURL];
                NSString *backup = [NSString stringWithFormat:@"%@/Info.bak", url];
                [fileManager removeItemAtPath:backup error:&removeError];
                [fileManager copyItemAtPath:path toPath:backup error:&error];
                [infoDict removeObjectForKey:@"CFBundleURLTypes"];
                if ([infoDict writeToFile:[infoPlistURL path] atomically:YES]) {
                    NSLog(@"[vnbp] Removed custom URL scheme from %@", url.lastPathComponent);
                } else {
                    NSLog(@"[vnbp] Error writing Info.plist for %@", url.lastPathComponent);
                }
            }
        }
    }
}

void revertCustomURLSchemeFromApps() {
    NSArray<NSURL *> *urls = getAppUrls();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSURL *url in urls) {
        if (![url.pathExtension isEqualToString:@"app"]) {
            continue;
        }
        NSURL *infoPlistURL = [url URLByAppendingPathComponent:@"Info.plist"];
        if ([fileManager fileExistsAtPath:infoPlistURL.path]) {
            NSLog(@"Found Info.plist %@", infoPlistURL);
            NSString *path = [NSString stringWithFormat:@"%@", infoPlistURL];
            NSString *backup = [NSString stringWithFormat:@"%@/Info.bak", url];
            if ([fileManager fileExistsAtPath:backup]) {
                NSError *error;
                NSError *removeError;
                [fileManager removeItemAtPath:path error:&removeError];
                if ([fileManager copyItemAtPath:backup toPath:path error:&error] && [fileManager removeItemAtPath:backup error:&removeError]) {
                    NSLog(@"[vnbp] Reverted custom URL scheme from %@", url.lastPathComponent);
                } else {
                    NSLog(@"[vnbp] Error writing Info.plist for %@", url.lastPathComponent);
                }
            }
        }
    }
}
