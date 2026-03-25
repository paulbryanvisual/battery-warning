import AppKit
import SwiftUI

class BannerWindowManager {
    static let shared = BannerWindowManager()
    private var window: NSWindow?
    
    func showBanner(percentage: Int, dismissAction: @escaping () -> Void) {
        if window == nil {
            let view = VStack(spacing: 0) {
                HStack(spacing: 20) {
                    Image(systemName: "battery.25")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Battery at \(percentage)%")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Your executive function assistant reminds you: find your charger soon.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        dismissAction()
                        self.hideBanner()
                    }) {
                        Text("Dismiss")
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(24)
            }
            .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .frame(width: 480)
            
            let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 480, height: 120),
                                styleMask: [.nonactivatingPanel, .borderless],
                                backing: .buffered,
                                defer: false)
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            
            panel.contentView = NSHostingView(rootView: view)
            
            // Position at top center
            if let screen = NSScreen.main {
                let x = screen.frame.midX - 240
                let y = screen.frame.maxY - 150
                panel.setFrameOrigin(NSPoint(x: x, y: y))
            } else {
                panel.center()
            }
            
            self.window = panel
        }
        
        // Show without stealing focus
        window?.orderFront(nil)
    }
    
    func hideBanner() {
        window?.orderOut(nil)
        window = nil
    }
}

// Helper for NSVisualEffectView in SwiftUI
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
