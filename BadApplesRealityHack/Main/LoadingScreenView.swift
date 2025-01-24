import SwiftUI

struct LoadingScreenView: View {
    @State private var loadingProgress: Double = 0.0
    @State private var loadingText: String = "Preparing Medical Simulation..."
    @State private var rotationAngle: Double = 0.0
    @State private var scale: CGFloat = 1.0
    
    // States for floating symbols
    @State private var positions: [CGPoint] = (0..<6).map { _ in
        CGPoint(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 50...700))
    }
    @State private var symbolScales: [CGFloat] = (0..<6).map { _ in CGFloat.random(in: 0.5...1.5) }
    
    let medicalSymbols = [
        "cross.case.fill",
        "heart.fill",
        "brain.head.profile",
        "pills.fill",
        "bandage.fill",
        "waveform.path.ecg"
    ]
    
    let loadingTexts = [
        "Calling All Doctors! 👨‍⚕️",
        "Preparing Your Medical Tools 🩺",
        "Connecting to Vision Pro Patient 🤝",
        "Loading Fun Medical Cases 🏥",
        "Almost Ready to Play! 🎮"
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating medical symbols
            ForEach(0..<medicalSymbols.count, id: \.self) { index in
                Image(systemName: medicalSymbols[index])
                    .font(.system(size: 30))
                    .foregroundColor(.blue.opacity(0.6))
                    .scaleEffect(symbolScales[index])
                    .position(positions[index])
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true),
                        value: positions[index]
                    )
            }
            
            VStack {
                Spacer()
                
                // Main icon with pulse animation
                ZStack {
                    Image(systemName: "stethoscope.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scale)
                        .shadow(color: .blue.opacity(0.5), radius: 10)
                    
                    // Pulse effect
                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .frame(width: 170, height: 170)
                        .scaleEffect(scale)
                        .opacity(2 - scale)
                }
                .padding()
                
                Text("Medical Mystery")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 2)
                
                Text("Get Ready to Diagnose!")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                Text(loadingText)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // Custom progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 250, height: 10)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 250 * loadingProgress, height: 10)
                        .foregroundColor(.blue)
                        .animation(.easeInOut, value: loadingProgress)
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .onAppear {
            startLoadingSimulation()
            startAnimations()
        }
    }
    
    private func startLoadingSimulation() {
        let totalDuration = 5.0 // Total loading time in seconds
        
        for (index, text) in loadingTexts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (totalDuration/Double(loadingTexts.count)) * Double(index)) {
                loadingText = text
                withAnimation {
                    loadingProgress = Double(index + 1) / Double(loadingTexts.count)
                }
            }
        }
    }
    
    private func startAnimations() {
        // Rotate main icon
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
        
        // Animate floating symbols
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in 0..<positions.count {
                positions[i].x += CGFloat.random(in: -1...1)
                positions[i].y += CGFloat.random(in: -1...1)
                
                // Keep symbols within bounds
                positions[i].x = min(max(positions[i].x, 50), 300)
                positions[i].y = min(max(positions[i].y, 50), 700)
            }
        }
    }
}

#Preview {
    LoadingScreenView()
} 