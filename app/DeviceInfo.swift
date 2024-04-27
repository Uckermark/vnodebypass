import Foundation
import UIKit
import MachO
import libroot

public class DeviceInfo: ObservableObject {
    
    static func isBypassed() -> Bool {
        return (access(jbRootPath("/bin/sh"), F_OK) != 0)
    }

    static func getShownPaths() -> Int {
        let name = ProcessInfo.processInfo.processName
        let path = jbRootPath("/usr/bin/\(name)")
        let opts: [String] = Preferences.shared.extensive ? ["-c", "-e"] : ["-c"]
        let cmd = spawn(command: path, args: opts, root: true)
        if(cmd.0 != 0) {
            return -1
        }
        let output = cmd.1

        let lines = output.components(separatedBy: .newlines)

        let endsWithTwo = lines.filter { $0.hasSuffix("0") }
        return endsWithTwo.count
    }

    static func checkDYLD() -> Bool {
        
        let suspiciousLibraries = [
            "SubstrateLoader.dylib",
            "SSLKillSwitch2.dylib",
            "SSLKillSwitch.dylib",
            "MobileSubstrate.dylib",
            "TweakInject.dylib",
            "CydiaSubstrate",
            "cynject",
            "CustomWidgetIcons",
            "PreferenceLoader",
            "RocketBootstrap",
            "WeeLoader",
            "/.file",
            "libhooker",
            "SubstrateInserter",
            "SubstrateBootstrap",
            "ABypass",
            "FlyJB",
            "Substitute",
            "Cephei",
            "Electra",
            "AppSyncUnified-FrontBoard.dylib",
            "Shadow"
        ]
        
        for libraryIndex in 0..<_dyld_image_count() {
            
            // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }
            
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    NSLog("[vnbp] Suspicious library loaded: \(loadedLibrary)")
                    return false
                }
            }
        }
        
        return true
    }

    static func checkExistenceOfSuspiciousFiles() -> Int {
        var paths = [
            "/var/mobile/Library/Preferences/ABPattern", // A-Bypass
            "/usr/lib/ABDYLD.dylib", // A-Bypass,
            "/usr/lib/ABSubLoader.dylib", // A-Bypass
            "/usr/sbin/frida-server", // frida
            "/etc/apt/sources.list.d/electra.list", // electra
            "/etc/apt/sources.list.d/sileo.sources", // electra
            "/.bootstrapped_electra", // electra
            "/usr/lib/libjailbreak.dylib", // electra
            "/jb/lzma", // electra
            "/.cydia_no_stash", // unc0ver
            "/.installed_unc0ver", // unc0ver
            "/jb/offsets.plist", // unc0ver
            "/usr/share/jailbreak/injectme.plist", // unc0ver
            "/etc/apt/undecimus/undecimus.list", // unc0ver
            "/var/lib/dpkg/info/mobilesubstrate.md5sums", // unc0ver
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist", // unc0ver
            "/jb/amfid_payload.dylib", // unc0ver
            "/jb/libjailbreak.dylib", // unc0ver
            "/usr/libexec/cydia/firmware.sh",
            "/var/lib/cydia",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/Users/",
            "/var/log/apt",
            "/Applications/Cydia.app",
            "/private/var/stash",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/private/var/tmp/cydia.log",
            "/Applications/Icy.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/blackra1n.app",
            "/Applications/SBSettings.app",
            "/Applications/FakeCarrier.app",
            "/Applications/WinterBoard.app",
            "/Applications/IntelliScreen.app",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/Applications/Sileo.app",
            "/var/binpack",
            "/Library/PreferenceBundles/LibertyPref.bundle",
            "/Library/PreferenceBundles/ShadowPreferences.bundle",
            "/Library/PreferenceBundles/ABypassPrefs.bundle",
            "/Library/PreferenceBundles/FlyJBPrefs.bundle",
            "/Library/PreferenceBundles/Cephei.bundle",
            "/Library/PreferenceBundles/SubstitutePrefs.bundle",
            "/Library/PreferenceBundles/libhbangprefs.bundle",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/usr/lib/substrate",
            "/usr/lib/TweakInject",
            "/var/binpack/Applications/loader.app", // checkra1n
            "/Applications/FlyJB.app", // Fly JB X
            "/Applications/Zebra.app", // Zebra
            "/Library/BawAppie/ABypass", // ABypass
            "/Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.plist", // SSL Killswitch
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.plist", // PreferenceLoader
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib", // PreferenceLoader
            "/Library/MobileSubstrate/DynamicLibraries", // DynamicLibraries directory in general
            "/var/mobile/Library/Preferences/me.jjolano.shadow.plist"
        ]
        
        // These files can give false positive in the emulator
        if true {
            paths += [
                "/bin/bash",
                "/usr/sbin/sshd",
                "/usr/libexec/ssh-keysign",
                "/bin/sh",
                "/etc/ssh/sshd_config",
                "/usr/libexec/sftp-server",
                "/usr/bin/ssh"
            ]
        }
        
        var count: Int = 0
        for path in paths {
            if FileManager.default.fileExists(atPath: jbRootPath(path)) {
                NSLog("[vnbp] Suspicious file detected: \(path)")
                count += 1
            }
        }
        
        return count
    }
}