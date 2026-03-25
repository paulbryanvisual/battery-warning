import SwiftUI
import AppKit
import Combine

@main
struct ADHBatteryApp: App {
    @NSApplicationDelegateAdaptor(ADHBatteryDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            Text("Settings Placeholder")
                .frame(width: 300, height: 200)
        }
    }
}

class ADHBatteryDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var statusMenuItem: NSMenuItem?
    var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "battery.100.bolt", accessibilityDescription: "adhBattery")
        }
        
        setupMenu()
        LockdownController.shared.start()
        
        BatteryMonitorTracker.shared.$batteryPercentage
            .combineLatest(BatteryMonitorTracker.shared.$isCharging)
            .receive(on: RunLoop.main)
            .sink { [weak self] percentage, isCharging in
                self?.updateStatus(percentage: percentage, isCharging: isCharging)
            }
            .store(in: &cancellables)
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        statusMenuItem = NSMenuItem(title: "Status: Unknown", action: nil, keyEquivalent: "")
        menu.addItem(statusMenuItem!)
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Test 20% Gentle Warning", action: #selector(testGentle), keyEquivalent: "g"))
        menu.addItem(NSMenuItem(title: "Test 10% Warning", action: #selector(testWarning), keyEquivalent: "w"))
        menu.addItem(NSMenuItem(title: "Test 5% Lockdown", action: #selector(testLockdown), keyEquivalent: "l"))
        menu.addItem(NSMenuItem.separator())
        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLoginItem), keyEquivalent: "")
        loginItem.state = LoginItemManager.shared.isEnabled ? .on : .off
        menu.addItem(loginItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit adhBattery", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleLoginItem(_ sender: NSMenuItem) {
        LoginItemManager.shared.toggle()
        sender.state = LoginItemManager.shared.isEnabled ? .on : .off
    }
    
    @objc func testGentle() {
        LockdownController.shared.testGentle()
    }
    
    @objc func testWarning() {
        LockdownController.shared.testWarning()
    }
    
    @objc func testLockdown() {
        LockdownController.shared.testCritical()
    }
    
    func updateStatus(percentage: Int, isCharging: Bool) {
        statusMenuItem?.title = "Battery: \(percentage)% (\(isCharging ? "Charging" : "Discharging"))"
        
        if let button = statusItem?.button {
            let iconName = isCharging ? "icon-white" : "icon-black"
            if let image = NSImage(named: iconName) ?? NSImage(contentsOfFile: Bundle.main.path(forResource: iconName, ofType: "svg") ?? "") {
                image.isTemplate = true
                button.image = image
            }
            button.image?.accessibilityDescription = "adhBattery"
        }
    }
}
