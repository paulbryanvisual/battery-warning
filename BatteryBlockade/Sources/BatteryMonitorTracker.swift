import Foundation
import IOKit.ps

class BatteryMonitorTracker: ObservableObject {
    static let shared = BatteryMonitorTracker()
    
    @Published var batteryPercentage: Int = 100
    @Published var isCharging: Bool = false
    
    private var timer: Timer?

    init() {
        updateBatteryState()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.updateBatteryState()
        }
        
        // Also fire immediately when app starts
        RunLoop.main.add(timer!, forMode: .common)
    }

    func updateBatteryState() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for ps in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: Any]
            
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = info[kIOPSMaxCapacityKey] as? Int {
                DispatchQueue.main.async {
                    self.batteryPercentage = Int((Double(capacity) / Double(maxCapacity)) * 100)
                }
            }
            
            if let isCharging = info[kIOPSIsChargingKey] as? Bool {
                DispatchQueue.main.async {
                    self.isCharging = isCharging
                }
            }
            
            // Just need one battery source, usually the primary one
            break
        }
    }
}
