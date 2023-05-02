import SwiftUI

struct RootView: View {
	@ObservedObject var ctrl: Controller

	init() {
		ctrl = Controller()
	}

	var body: some View {
        VStack {
            HStack {
                Spacer()
                SettingsButton()
            }
            Spacer()
            BypassButton()
            Spacer()
        }
    }
}
