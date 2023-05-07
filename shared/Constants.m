#import <Foundation/Foundation.h>

NSArray<NSURL *> *getAppUrls(void) {
    NSArray<NSURL *> *hAppUrls = @[
        [NSURL URLWithString:@"/Applications/Cydia.app"],
        [NSURL URLWithString:@"/Applications/Sileo.app"],
        [NSURL URLWithString:@"/Applications/SileoNightly.app"],
        [NSURL URLWithString:@"/Applications/Zebra.app"],
        [NSURL URLWithString:@"/Applications/Installer.app"],
        [NSURL URLWithString:@"/Applications/Filza.app"]
    ];
    return hAppUrls;
}