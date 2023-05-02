import SwiftUI
import Foundation

struct SettingsButton: View {
    @State var settings: Bool = false

	var body: some View {
		 Button(action: { settings.toggle() }) { Image(systemName: "gear") }
            .padding()
            .foregroundColor(.white)
            .cornerRadius(10)
            .sheet(isPresented: $settings) {
                SettingsView()
            }
    }
}

struct SettingsView: View {
    @State var files: Int = DeviceInfo.getShownPaths()

	var body: some View {
		 NavigationView {
            Text("\(files) files detected")
            .onAppear {
                files = DeviceInfo.getShownPaths()
            }
            .navigationBarTitle("Settings", displayMode: .inline)
         }
    }
}