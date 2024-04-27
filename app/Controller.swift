import Foundation
import UIKit
import libroot


class Controller: ObservableObject {
    @Published var isBypassed: Bool
    @Published var isWorking: Bool

    init() {
        isBypassed = DeviceInfo.isBypassed()
        isWorking = false
    }

    func run() {
        guard !isWorking else { return }
        isWorking = true
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.isBypassed { self.removeCustomURLSchemeFromApps() }
            let name = ProcessInfo.processInfo.processName
            let path = jbRootPath("/usr/bin/\(name)")
            var opts1: [String] = self.isBypassed ? ["-r"] : ["-s"]
            let opts2: [String] = self.isBypassed ? ["-R"] : ["-h"]
            if (Preferences.shared.extensive && opts1 == ["-s"]) { opts1.append("-e") }
            let cmd1 = spawn(command: path, args: opts1, root: true)
            let cmd2 = spawn(command: path, args: opts2, root:true)
            if self.isBypassed { self.revertCustomURLSchemeFromApps() }
            DispatchQueue.main.async {
                if(cmd1.0 == 0 && cmd2.0 == 0) {
                    self.isBypassed.toggle()
                }
                self.isWorking = false
            }
        }
    }

    func respring() {
        guard let window = UIApplication.shared.windows.first else { return }
        while true {
           window.snapshotView(afterScreenUpdates: false)
        }
    }

    private func removeCustomURLSchemeFromApps() {
        guard !isBypassed else { return }
        let path = jbRootPath("/usr/bin/\(ProcessInfo.processInfo.processName)")
        spawn(command: path, args: ["-u"], root: true)
        for url in getAppUrls() {
            spawn(command: jbRootPath("/usr/bin/uicache"), args: ["-p", url.absoluteString], root: true)
        }
    }

    private func revertCustomURLSchemeFromApps() {
        guard !isBypassed else { return }
        let path = jbRootPath("/usr/bin/\(ProcessInfo.processInfo.processName)")
        spawn(command: path, args: ["-U"], root: true)
        for url in getAppUrls() {
            spawn(command: jbRootPath("/usr/bin/uicache"), args: ["-p", url.absoluteString], root: true)
        }
    }
}