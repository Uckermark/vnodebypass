import Foundation

class Controller: ObservableObject {
    var isBypassed: Bool

    init() {
        isBypassed = access("/bin/sh", F_OK) != 0;
    }

    func run() {
        let name = ProcessInfo.processInfo.processName
        var opts: [String] = []
        if !self.isBypassed {
            opts = ["-s", "-h"]
        } else {
            opts = ["-r", "-R"]
        }
        let cmd1 = spawn(command: name, args: [opts[0]], root: true)
        NSLog("[\(name)] cmd1: \(cmd1.0) \(cmd1.1)")
        let cmd2 = spawn(command: name, args: [opts[1]], root:true)
        NSLog("[\(name)] cmd2: \(cmd2.0) \(cmd2.1)")
    }
}