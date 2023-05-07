import Foundation
import UIKit

class Controller: ObservableObject {
    @Published var showRespring: Bool
    @Published var isBypassed: Bool

    init() {
        isBypassed = DeviceInfo.isBypassed()
        showRespring = false
    }

    func run() {
        if !isBypassed { removeCustomURLSchemeFromApps() }
        let name = ProcessInfo.processInfo.processName
        let path = "/usr/bin/\(name)"
        var opts1: [String] = self.isBypassed ? ["-r"] : ["-s"]
        let opts2: [String] = self.isBypassed ? ["-R"] : ["-h"]
        if (Preferences.shared.extensive && opts1 == ["-s"]) { opts1.append("-e") }
        let cmd1 = spawn(command: path, args: opts1, root: true)
        let cmd2 = spawn(command: path, args: opts2, root:true)
        if isBypassed { revertCustomURLSchemeFromApps() }
        if(cmd1.0 == 0 && cmd2.0 == 0) {
            self.isBypassed.toggle()
            self.showRespring.toggle()
        }
    }

    func respring() {
        guard let window = UIApplication.shared.windows.first else { return }
        while true {
           window.snapshotView(afterScreenUpdates: false)
        }
    }

    func removeCustomURLSchemeFromApps() {
        guard !isBypassed else { return }
        let path = "/usr/bin/\(ProcessInfo.processInfo.processName)"
        spawn(command: path, args: ["-u"], root: true)
        for url in getAppUrls() {
            spawn(command: "/usr/bin/uicache", args: ["-p", url.absoluteString], root: true)
        }
    }

    func revertCustomURLSchemeFromApps() {
        guard !isBypassed else { return }
        let path = "/usr/bin/\(ProcessInfo.processInfo.processName)"
        spawn(command: path, args: ["-U"], root: true)
        for url in getAppUrls() {
            spawn(command: "/usr/bin/uicache", args: ["-p", url.absoluteString], root: true)
        }
    }
}