import SwiftUI

struct LockdownView: View {
    let percentage: Int
    let isCritical: Bool
    var dismissAction: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "battery.0")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                
                Text(isCritical ? "CRITICAL BATTERY: \(percentage)%" : "LOW BATTERY: \(percentage)%")
                    .font(.system(size: 60, weight: .black))
                    .foregroundColor(.white)
                
                Text(isCritical ? "PLUG IN YOUR MAC IMMEDIATELY." : "Your battery is getting low. We recommend plugging it in soon to avoid disruption.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if !isCritical {
                    Button(action: {
                        dismissAction?()
                    }) {
                        Text("I'll plug it in soon")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 40)
                } else {
                    Button(action: {
                        dismissAction?()
                    }) {
                        Text("Snooze for 1% battery life")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 40)
                    
                    Text("This screen will disappear automatically when connected to power.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
