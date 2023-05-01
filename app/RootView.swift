import SwiftUI

struct RootView: View {
	@ObservedObject var ctrl: Controller

	init() {
		ctrl = Controller()
	}

	var body: some View {
		Button("Text", action: ctrl.run)
    }
}
