import SwiftUI
import RealityKit
import ARKit

let qrCodeAnchor = AnchorEntity(.image(group: "ARResources", name: "AppClip"))

enum GameType: String, CaseIterable, Hashable {
    case diagnosis = "Diagnosis"
    case xray = "X-Ray Analysis"
    case labTest = "Lab Test"
    case surgery = "Surgery"
    case ultrasound = "Ultrasound"
    case mri = "MRI Scan"
    case cardiology = "Cardiology"
    case neurology = "Neurology"
    case pediatrics = "Pediatrics"
    case emergency = "Emergency"
    case dental = "Dental"
    case ophthalmology = "Eye Care"
    case dermatology = "Skin Care"
    case orthopedics = "Orthopedics"
    case psychology = "Psychology"
    
    var icon: String {
        switch self {
        case .diagnosis: return "stethoscope"
        case .xray: return "rays"
        case .labTest: return "flask.fill"
        case .surgery: return "cross.case.fill"
        case .ultrasound: return "waveform"
        case .mri: return "brain.head.profile"
        case .cardiology: return "heart.fill"
        case .neurology: return "brain"
        case .pediatrics: return "figure.child"
        case .emergency: return "bolt.heart.fill"
        case .dental: return "mouth.fill"
        case .ophthalmology: return "eye.fill"
        case .dermatology: return "hand.raised.fill"
        case .orthopedics: return "figure.walk"
        case .psychology: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .diagnosis: return .blue
        case .xray: return .purple
        case .labTest: return .green
        case .surgery: return .red
        case .ultrasound: return .cyan
        case .mri: return .orange
        case .cardiology: return .pink
        case .neurology: return .indigo
        case .pediatrics: return .yellow
        case .emergency: return .red
        case .dental: return .mint
        case .ophthalmology: return .teal
        case .dermatology: return .brown
        case .orthopedics: return .gray
        case .psychology: return .purple
        }
    }
}

class CameraViewModel: ObservableObject {
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
    @State private var selectedGame: GameType = .diagnosis
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                RealityView { content in
                    content.camera = .spatialTracking
                    content.add(rootEntity)
                    rootEntity.position = .init(x: 0, y: 0, z: 0)
                    
                    if let newHeart = try? await ModelEntity(named: "heart1") {
                        newHeart.scale = .init(repeating: 0.001)
                       // content.add(newHeart)
                    }
                    
                    cameraAnchor.components.set(AnchoringComponent(.camera, trackingMode: .continuous))
                    rootEntity.addChild(cameraAnchor)
                    
                    cameraAnchor.addChild(childAnchor)
                    childAnchor.position = .init(x: 0, y: 0, z: 0)
                    
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
                
                GameSelector()
                    .padding(.bottom, 30)
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

struct GameSelector: View {
    @State private var selectedGameTitle: String = "No game selected"
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    var body: some View {
        VStack {
            // Debug text to show current selection
            Text(selectedGameTitle)
                .foregroundColor(.white)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(GameType.allCases, id: \.self) { game in
                        GameCircle(game: game)
                            .onTapGesture {
                                selectedGameTitle = "Selected: \(game.rawValue)"
                                print("Tapped: \(game.rawValue)")
                                // Optional: Add haptic feedback
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 100)
        }
    }
}
struct GameCircle: View {
    let game: GameType
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(game.color.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: game.icon)
                    .font(.system(size: 30))
                    .foregroundColor(game.color)
            }
            
            Text(game.rawValue)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: 70) // Added fixed width for better text wrapping
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
