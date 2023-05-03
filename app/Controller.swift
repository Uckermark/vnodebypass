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
        let name = ProcessInfo.processInfo.processName
        let path = "/usr/bin/\(name)"
        var opts1: [String] = self.isBypassed ? ["-r"] : ["-s"]
        let opts2: [String] = self.isBypassed ? ["-R"] : ["-h"]
        if (Preferences.shared.extensive && opts1 == ["-s"]) { opts1.append("-e") }
        let cmd1 = spawn(command: path, args: opts1, root: true)
        let cmd2 = spawn(command: path, args: opts2, root:true)
        if(cmd1.0 == 0 && cmd2.0 == 0) {
            self.isBypassed.toggle()
            self.showRespring.toggle()
        }
    }

    func respring() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        view.alpha = 0

        for window in UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).flatMap({ $0.windows.map { $0 } }) {
            window.addSubview(view)
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                view.alpha = 1
            })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            restartFrontboard()
            sleep(2) // give the springboard some time to restart before exiting
            exit(0)
        })
    }
}