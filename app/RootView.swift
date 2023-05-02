import SwiftUI

struct RootView: View {
	@ObservedObject var ctrl: Controller

	init() {
		ctrl = Controller()
	}

	var body: some View {
		Button(ctrl.isBypassed ?  "Enable Tweaks" : "Bypass",
                   action: ctrl.run )
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .alert(isPresented: $ctrl.showRespring) { // show respring alert
                Alert(
                    title: Text("Respring device?"),
                    message: Text("It is highly recommended to respring."),
                    primaryButton: .destructive(Text("No")),
                    secondaryButton: .default(Text("Yes"), action: {
                    ctrl.respring()
                    })
                )
            }
    }
}
