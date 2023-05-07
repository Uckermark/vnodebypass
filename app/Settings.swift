import SwiftUI
import Foundation

struct SettingsButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State var settings: Bool = false

	var body: some View {
		 Button(action: { settings.toggle() }) { Image(systemName: "gear") }
            .padding()
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .cornerRadius(10)
            .sheet(isPresented: $settings) {
                SettingsView()
            }
    }
}

struct SettingsView: View {
    @ObservedObject var prefs: Preferences = Preferences.shared
    @State var files: Int = -1
    @State var isBypassed: Bool = false
    @State var dlydCheck: Bool = false
    @State var susFiles: Bool = false
    @State var initDone: Bool = false

	var body: some View {
		 NavigationView {
            List {
                Section {
                    if(initDone) {
                        Text("\(isBypassed ? "System is bypassed" : "System is not bypassed")")
                        Text("\(dlydCheck ? "Dyld check passed" : "Dyld check failed")")
                        Text("\(susFiles ? "No sus files found" : "Found \(files) sus files")")
                    } else {
                        Text("Checking system...")
                    }
                }
                Section {
                    Button("Respring", action: Controller().respring)
                    Toggle("Enable extensive mode (EXPERIMENTAL)", isOn: $prefs.extensive)
                    .onChange(of: prefs.extensive) { value in
                        self.update()
                    }
                }
                /*Section(header: Text("CREDITS")) {
                    let credits = ["XsF1re", "ichitaso", "plus007", "Uckermark"]
                    ForEach(credits, id: \.self) { name in
                        Text(name)
                    }
                }*/
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
         }
         .onAppear {
            self.update()
        }
    }

    private func update() {
        DispatchQueue.global(qos: .utility).async {
            let dIsBypassed = DeviceInfo.isBypassed()
            let dFiles = DeviceInfo.getShownPaths()
            let dSusFiles = DeviceInfo.checkExistenceOfSuspiciousFiles()
            let dDyldCheck = DeviceInfo.checkDYLD()
            DispatchQueue.main.async {
                isBypassed = dIsBypassed
                files = dFiles
                susFiles = dSusFiles
                dlydCheck = dDyldCheck
                initDone = true
            }
        }
    }
}