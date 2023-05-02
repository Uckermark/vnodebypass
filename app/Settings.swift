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
    @State var dlydCheck: Bool = DeviceInfo.checkDYLD()
    @State var susFiles: Bool = DeviceInfo.checkExistenceOfSuspiciousFiles()

	var body: some View {
		 NavigationView {
            List {
                Section() {
                    Text("\(files) files detected")
                    Text("\(isBypassed ? "System is bypassed" : "System is not bypassed")")
                    Text("\(dlydCheck ? "Dyld check passed" : "Dyld check failed")")
                    Text("\(susFiles ? "No sus files found" : "Found sus files")")
                    Button("Respring", action: Controller().respring)
                }
                Section(header: Text("CREDITS")) {
                    let credits = ["XsF1re", "ichitaso", "plus007", "Uckermark"]
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
            dlydCheck = DeviceInfo.checkDYLD()
            susFiles = DeviceInfo.checkExistenceOfSuspiciousFiles()
        }
    }
}