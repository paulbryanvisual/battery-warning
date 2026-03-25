import AppKit
import SwiftUI

class LockdownWindowManager {
    static let shared = LockdownWindowManager()
    private var windows: [NSWindow] = []
    
    func showLockdown(percentage: Int, isCritical: Bool, dismissAction: @escaping () -> Void) {
        hideLockdown()
        
        // App Store Compliant Presentation Options
        // We only hide the dock and menu bar to create an immersive, distraction-free overlay.
        // We specifically avoid .disableForceQuit or .disableProcessSwitching which are restricted in the App Store sandbox.
        let options: NSApplication.PresentationOptions = [.hideDock, .hideMenuBar]
        
        for screen in NSScreen.screens {
            let window = NSWindow(contentRect: screen.frame,
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: false)
            
            // screenSaver level forces it over other common windows but avoids hardware-level capture
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.backgroundColor = .black
            window.isOpaque = true
            window.hasShadow = false
            window.canHide = false
            
            let view = LockdownView(percentage: percentage, isCritical: isCritical) { [weak self] in
                self?.hideLockdown()
                dismissAction()
            }
            
            window.contentView = NSHostingView(rootView: view)
            windows.append(window)
            
            window.setFrame(screen.frame, display: true)
            window.makeKeyAndOrderFront(nil)
        }
        
        NSApp.presentationOptions = options
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideLockdown() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
        NSApp.presentationOptions = []
    }
}
