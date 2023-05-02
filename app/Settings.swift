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
    @State var isBypassed: Bool = DeviceInfo.isBypassed()

	var body: some View {
		 NavigationView {
            List {
                Section() {
                    Text("\(files) files detected")
                    Text("\(isBypassed ? "System is bypassed" : "System is not bypassed")")
                    Button("Respring", action: Controller().respring)
                }
                Section(header: Text("CREDITS")) {
                    let credits = ["XsF1re", "ichitaso", "Uckermark", "plus007", "LeminLimez", "Amy While"]
                    ForEach(credits, id: \.self) { name in
                        Text(name)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
         }
         .onAppear {
            isBypassed = DeviceInfo.isBypassed()
            files = DeviceInfo.getShownPaths()
        }
    }
}