import Foundation
import Combine
import AppKit

class LockdownController {
    static let shared = LockdownController()
    private var cancellables = Set<AnyCancellable>()
    
    var gentleThreshold = 20
    var warningThreshold = 10
    var criticalThreshold = 5
    
    private var isGentleActive = false
    private var isWarningActive = false
    private var isCriticalActive = false
    private var snoozedBatteryPercentage: Int?
    
    init() {
        BatteryMonitorTracker.shared.$batteryPercentage
            .combineLatest(BatteryMonitorTracker.shared.$isCharging)
            .receive(on: RunLoop.main)
            .sink { [weak self] percentage, isCharging in
                self?.handleBatteryUpdate(percentage: percentage, isCharging: isCharging)
            }
            .store(in: &cancellables)
            
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            let battery = BatteryMonitorTracker.shared.batteryPercentage
            let charging = BatteryMonitorTracker.shared.isCharging
            self?.handleBatteryUpdate(percentage: battery, isCharging: charging)
        }
    }
    
    func start() {
        // Initializes the observer
    }
    
    private func handleBatteryUpdate(percentage: Int, isCharging: Bool) {
        if isCharging {
            if isWarningActive || isCriticalActive || isGentleActive {
                LockdownWindowManager.shared.hideLockdown()
                BannerWindowManager.shared.hideBanner()
                isWarningActive = false
                isCriticalActive = false
                isGentleActive = false
            }
            snoozedBatteryPercentage = nil
            return
        }
        
        if let snoozedAt = snoozedBatteryPercentage {
            if percentage >= snoozedAt {
                return
            } else {
                snoozedBatteryPercentage = nil
            }
        }
        
        if percentage <= criticalThreshold {
            if !isCriticalActive {
                isCriticalActive = true
                isWarningActive = false
                isGentleActive = false
                BannerWindowManager.shared.hideBanner()
                LockdownWindowManager.shared.showLockdown(percentage: percentage, isCritical: true) { [weak self] in
                    self?.snoozedBatteryPercentage = percentage
                    self?.isCriticalActive = false
                }
            }
        } else if percentage <= warningThreshold {
            if !isWarningActive && !isCriticalActive {
                isWarningActive = true
                isGentleActive = false
                BannerWindowManager.shared.hideBanner()
                LockdownWindowManager.shared.showLockdown(percentage: percentage, isCritical: false) { [weak self] in
                    self?.snoozedBatteryPercentage = self?.criticalThreshold
                    self?.isWarningActive = false
                }
            }
        } else if percentage <= gentleThreshold {
            if !isGentleActive && !isWarningActive && !isCriticalActive {
                isGentleActive = true
                BannerWindowManager.shared.showBanner(percentage: percentage) { [weak self] in
                    self?.snoozedBatteryPercentage = self?.warningThreshold
                    self?.isGentleActive = false
                }
            }
        } else {
            if isWarningActive || isCriticalActive || isGentleActive {
                LockdownWindowManager.shared.hideLockdown()
                BannerWindowManager.shared.hideBanner()
                isWarningActive = false
                isCriticalActive = false
                isGentleActive = false
            }
        }
    }
    
    func testGentle() {
        BannerWindowManager.shared.showBanner(percentage: gentleThreshold) { [weak self] in
            self?.isGentleActive = false
        }
    }
    
    func testWarning() {
        LockdownWindowManager.shared.showLockdown(percentage: warningThreshold, isCritical: false) { [weak self] in
            self?.isWarningActive = false
        }
    }
    
    func testCritical() {
        LockdownWindowManager.shared.showLockdown(percentage: criticalThreshold, isCritical: true) { [weak self] in
            self?.isCriticalActive = false
        }
    }
}
