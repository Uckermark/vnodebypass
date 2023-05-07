import SwiftUI

struct BypassButton: View {
	@ObservedObject var ctrl: Controller

	init() {
		ctrl = Controller()
	}

	var body: some View {
        if(!ctrl.isWorking) {
		    Button(ctrl.isBypassed ?  "Enable Tweaks" : "Bypass",
                       action: ctrl.run )
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        } else {
            Button("Please wait...", action: ctrl.respring)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(10)
                .disabled(true)
        }
    }
}