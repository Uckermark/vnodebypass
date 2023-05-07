import Foundation

class Preferences: ObservableObject {
    @Published var extensive: Bool {
        didSet {
            save()
        }
    }
    
    static let shared = Preferences()
    
    private init() {
        self.extensive = UserDefaults.standard.bool(forKey: "extensive")
        UserDefaults.standard.set(self.extensive, forKey: "extensive")
        UserDefaults.standard.synchronize()
    }
    
    func save() {
        UserDefaults.standard.set(self.extensive, forKey: "extensive")
        UserDefaults.standard.synchronize()
    }
}