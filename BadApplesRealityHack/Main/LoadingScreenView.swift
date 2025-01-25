import SwiftUI

struct LoadingScreenView: View {
    @State private var loadingProgress: Double = 0.0
    @State private var loadingText: String = "Preparing Medical Simulation..."
    @State private var rotation: Double = 0
    @State private var floatingSymbols: [(String, CGPoint, Double)] = [
        ("pill.fill", CGPoint(x: 50, y: 100), 0),
        ("cross.case.fill", CGPoint(x: 300, y: 100), 45),
        ("heart.fill", CGPoint(x: 100, y: 150), 90),
        ("lungs.fill", CGPoint(x: 250, y: 150), 180),
        ("brain.head.profile", CGPoint(x: 150, y: 50), 270)
    ]
    
    let loadingTexts = [
        "Calling All Doctors! 👨‍⚕️",
        "Preparing AR Magic! ✨",
        "Connecting to Vision Pro... 🥽",
        "Loading Medical Tools! 🩺",
        "Almost Ready to Play! 🎮"
    ]
    
    var body: some View {
        ZStack {
            // Vibrant gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FF6B6B"), Color(hex: "4ECDC4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Top section for floating symbols
            VStack {
                // Floating medical symbols contained in the top third
                ZStack {
                    ForEach(0..<floatingSymbols.count, id: \.self) { index in
                        Image(systemName: floatingSymbols[index].0)
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .position(floatingSymbols[index].1)
                            .rotationEffect(.degrees(floatingSymbols[index].2))
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 2...4))
                                    .repeatForever(autoreverses: true),
                                value: floatingSymbols[index].2
                            )
                    }
                }
                .frame(height: 200) // Constrain the floating symbols to this height
                
                Spacer()
            }
            
            // Main content
            VStack {
                Spacer()
                
                // Main stethoscope icon with rotation
                Image(systemName: "stethoscope.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .blur(radius: 20)
                    )
                    .rotationEffect(.degrees(rotation))
                    .padding()
                
                // Game title
                Text("Healing Heroes")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 5)
                
                Text("A SharePlay Experience")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.bottom, 30)
                
                // Loading text with emoji
                Text(loadingText)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "FF6B6B"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                
                // Custom progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.3))
                        .frame(width: 250, height: 10)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF6B6B"), Color(hex: "FFE66D")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 250 * loadingProgress, height: 10)
                        .animation(.easeInOut, value: loadingProgress)
                }
                .padding(.top, 20)
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .onAppear {
            startLoadingSimulation()
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            animateFloatingSymbols()
        }
    }
    
    private func startLoadingSimulation() {
        let totalDuration = 4.0 // Total loading time in seconds
        
        for (index, text) in loadingTexts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (totalDuration/Double(loadingTexts.count)) * Double(index)) {
                withAnimation {
                    loadingText = text
                    loadingProgress = Double(index + 1) / Double(loadingTexts.count)
                }
            }
        }
    }
    
    private func animateFloatingSymbols() {
        for index in 0..<floatingSymbols.count {
            withAnimation(Animation.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true)) {
                floatingSymbols[index].1.y += CGFloat.random(in: -50...50)
                floatingSymbols[index].2 += Double.random(in: -45...45)
            }
        }
    }
}

#Preview {
    LoadingScreenView()
}
