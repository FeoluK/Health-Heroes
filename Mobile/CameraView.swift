import SwiftUI
import RealityKit
import ARKit

let qrCodeAnchor = AnchorEntity(.image(group: "ARResources", name: "AppClip"))
var devicePositionAnchor: ModelEntity = ModelEntity(mesh: .generateSphere(radius: 0.2), materials: [UnlitMaterial(color: .blue)])

class CameraViewModel: ObservableObject {
    let rootEntity = Entity()
    let currentObjectRoot = Entity()
    
    func spawnFloor() {
        let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50))
        floor.generateCollisionShapes(recursive: true)
        rootEntity.addChild(floor)
    }
}

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showPermissionAlert = false
    @State private var showRules = false
    @State private var showLeaderboard = false
    @State private var showCustomMenu = false
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                RealityView { content in
                    content.camera = .spatialTracking
                    
                    content.add(devicePositionAnchor)
                    
                    let entity = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
                    qrCodeAnchor.addChild(entity)
                    entity.position += .init(x: 0, y: 1, z: 0)
                    content.add(qrCodeAnchor)
                    
                } update: { content in
                    GameModeManager.shared.handleSceneUpdate()
                }.gesture(dragGesture)
            } else {
                // Fallback on earlier versions
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    ZStack(alignment: .topTrailing) {
                        Button(action: {
                            showCustomMenu.toggle()
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        if showCustomMenu {
                            CustomMenuView(
                                isPresented: $showCustomMenu,
                                showRules: $showRules,
                                showLeaderboard: $showLeaderboard,
                                onQuit: { gameStateManager.gameState = .mainMenu }
                            )
                            .transition(.opacity)
                            .offset(y: 40)
                        }
                    }
                    .padding(.trailing, 12)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // No need to check permissions as RealityView handles it
        }
        .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
            Button("Go to Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Camera access is required for AR features. Please enable it in Settings.")
        }
        .overlay {
            if showRules {
                RulesView(isPresented: $showRules)
                    .transition(.opacity)
            }
            if showLeaderboard {
                LeaderboardView(isPresented: $showLeaderboard)
                    .transition(.opacity)
            }
        }
    }
    
    // Drag gesture for interaction
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                // Handle drag
            }
            .onEnded { _ in
                // Handle drag end
            }
    }
}

// Custom menu view
struct CustomMenuView: View {
    @Binding var isPresented: Bool
    @Binding var showRules: Bool
    @Binding var showLeaderboard: Bool
    let onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            MenuButton(title: "Rules", icon: "book.fill") {
                isPresented = false
                showRules = true
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            MenuButton(title: "Leaderboard", icon: "trophy.fill") {
                isPresented = false
                showLeaderboard = true
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            MenuButton(title: "Quit", icon: "xmark.circle.fill", isDestructive: true) {
                isPresented = false
                onQuit()
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
        )
        .frame(width: 160)
        .zIndex(1) // Ensure menu stays above other elements
    }
}

// Custom menu button
struct MenuButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14))
            }
            .foregroundColor(isDestructive ? .red : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }
}

// Rules popup view
struct RulesView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .opacity(0.95)
                    .cornerRadius(20)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Rules")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    
                    Text("Default rules text that can be edited later. This will contain information about how to play the medical simulation game and interact with the AR features.")
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 300)
        .shadow(radius: 10)
    }
}

// Leaderboard popup view
struct LeaderboardView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .opacity(0.95)
                    .cornerRadius(20)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Leaderboard")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    
                    // Placeholder leaderboard content
                    VStack(spacing: 15) {
                        LeaderboardRow(rank: 1, name: "Dr. Smith", score: 1200)
                        LeaderboardRow(rank: 2, name: "Dr. Johnson", score: 1100)
                        LeaderboardRow(rank: 3, name: "Dr. Williams", score: 1000)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 300)
        .shadow(radius: 10)
    }
}

// Helper view for leaderboard rows
struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let score: Int
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .bold()
                .frame(width: 40)
            Text(name)
            Spacer()
            Text("\(score)")
                .bold()
        }
    }
}

#Preview {
    CameraView()
}
