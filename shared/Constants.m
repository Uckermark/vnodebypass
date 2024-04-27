#include "Constants.h"

NSArray<NSURL *> *getAppUrls(void) {
    NSArray<NSURL *> *hAppUrls = @[
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/Cydia.app")],
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/Sileo.app")],
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/SileoNightly.app")],
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/Zebra.app")],
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/Installer.app")],
        [NSURL URLWithString:ROOT_PATH_NS(@"/Applications/Filza.app")]
    ];
    return hAppUrls;
}