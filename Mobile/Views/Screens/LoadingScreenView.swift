import SwiftUI

struct LoadingScreenView: View {
    @State private var loadingProgress: Double = 0.0
    @State private var loadingText: String = "Preparing Medical Simulation..."
    let loadingTexts = [
        "Initializing Medical Database...",
        "Calibrating AR Systems...",
        "Establishing SharePlay Connection...",
        "Loading Patient Profiles..."
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "stethoscope.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding()
            
            Text(loadingText)
                .font(.headline)
                .padding()
            
            ProgressView(value: loadingProgress)
                .progressViewStyle(.linear)
                .frame(width: 200)
                .tint(.blue)
            
            Spacer()
        }
        .onAppear {
            startLoadingSimulation()
        }
    }
    
    private func startLoadingSimulation() {
        // Simulate loading with different messages
        let totalDuration = 4.0 // Total loading time in seconds
        
        for (index, text) in loadingTexts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (totalDuration/Double(loadingTexts.count)) * Double(index)) {
                loadingText = text
                withAnimation {
                    loadingProgress = Double(index + 1) / Double(loadingTexts.count)
                }
            }
        }
    }
} 