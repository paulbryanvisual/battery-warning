import Foundation
import ServiceManagement

class LoginItemManager {
    static let shared = LoginItemManager()
    private let appBundleIdentifier = "com.bryanpaul.adhbattery"
    
    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                // Fallback for older versions if needed
                return false
            }
        }
    }
    
    func toggle() {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            if service.status == .enabled {
                try? service.unregister()
            } else {
                try? service.register()
            }
        }
    }
}
