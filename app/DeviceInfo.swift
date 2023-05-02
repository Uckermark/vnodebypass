import Foundation
import UIKit

public class DeviceInfo: ObservableObject {
    
    static func isBypassed() -> Bool {
        return (access("/bin/sh", F_OK) != 0)
    }

    static func getShownPaths() -> Int {
        let name = ProcessInfo.processInfo.processName
        let path = "/usr/bin/\(name)"
        let opts: [String] = ["-c"]
        let cmd = spawn(command: path, args: opts, root: true)
        if(cmd.0 != 0) {
            return -1
        }
        let output = cmd.1

        let lines = output.components(separatedBy: .newlines)

        let endsWithTwo = lines.filter { $0.hasSuffix("0") }
        return endsWithTwo.count
    }
}