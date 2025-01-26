import SwiftUI
import RealityFoundation
import Combine
import GroupActivities
import RealityKit
import SharePlayMessages


enum SessionAction {
    case openImmersiveSpace(String)
    case dismissImmersiveSpace(Void)
}

class GameStateManager: ObservableObject {
    static let shared = GameStateManager()
    
    // MARK: - Published Properties
    @Published var isLoading = true
    @Published var gameState: GameState = .loading
    @Published var currentGame: GameType?
    @Published var players: [UUID: Player] = [:]
    
    // MARK: - SharePlay Properties
    var tasks = Set<Task<Void, Never>>()
    var sharePlayMessages: [any SharePlayMessage] = []
    
    let actionSubject = PassthroughSubject<SessionAction, Never>()
    var sessionActionPublisher: AnyPublisher<SessionAction, Never> { actionSubject.eraseToAnyPublisher() }
    
    // MARK: - Game State Enum
    enum GameState {
        case loading
        case mainMenu
        case inGame
        case playing
        case paused
        case gameOver
        case lobbyIsReady
        case lobbyNotReady
    }
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - Game State Functions
    func startLoading() {
        isLoading = true
        gameState = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.finishLoading()
        }
    }
    
    private func finishLoading() {
        withAnimation {
            self.isLoading = false
            self.gameState = .mainMenu
        }
    }
    
    func resetGame() {
        gameState = .mainMenu
        currentGame = nil
    }
    
    func pauseGame() {
        gameState = .paused
    }
    
    func resumeGame() {
        gameState = .playing
    }
    
    func endGame() {
        gameState = .gameOver
    }
    
    // MARK: - SharePlay Message Handlers
    static func handleGameStartMsg(message: Game_StartMessage,
                                   sender: Participant) async
    {
        Task { @MainActor in
            GameStateManager.shared.gameState = .inGame
            
            Task { @MainActor in
                GameStateManager.shared.actionSubject.send(.openImmersiveSpace(message.gameMode))
            }
        }
    }
    
    static func handleHeartMessage(message: Game_SendHeartMessage,
                                   sender: Participant) async
    {
        Task { @MainActor in
            //  if currentPlatform() == .visionOS {
            if #available(iOS 18.0, *) {
                if let newHeart = try? await ModelEntity(named: "heart1") {
                    newHeart.name = "heart"
                    newHeart.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: [.generateBox(size: .init(repeating: 0.3))], mass: 10, mode: .kinematic)
                    newHeart.scale = .init(repeating: 0.0002)
                    newHeart.position = getSeatTileEntity(seat: message.seatNumber).position(relativeTo: nil)
                    let heartHeightAdd = currentPlatform() == .visionOS ? 1.2 : 0
                    newHeart.position.y = message.heartHeight + Float(heartHeightAdd)
                    newHeart.components[HeartMovementComponent.self] = HeartMovementComponent(targetPosition: getSeatTileEntity(seat: 1).position + .init(x: 0, y: 1.2, z: 0), ownerPlayerId: Player.local?.id ?? UUID())
                    
                    rootEntity.addChild(newHeart)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// New ECS Component System for Heart Movement

class HeartMovementComponent: Component {
    var targetPosition: SIMD3<Float>
    var ownerPlayerId: UUID
    
    init(targetPosition: SIMD3<Float>, ownerPlayerId: UUID) {
        self.targetPosition = targetPosition
        self.ownerPlayerId = ownerPlayerId
    }
}

class HeartMovementSystem: System {
    required init(scene: RealityKit.Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(
            EntityQuery(where: .has(HeartMovementComponent.self))
        )
        
        for entity in entities {
            guard let proximityComponent = entity.components[HeartMovementComponent.self] else {
                continue
            }
            
            let component = entity.components[HeartMovementComponent.self]
            let currentPosition = entity.position
            let direction = normalize((component?.targetPosition ?? .one) - currentPosition)
            let speed: Float = 0.6 // Adjust speed as needed
            entity.position += direction * speed * Float(context.deltaTime)
            
            let distance1 = entity.position.distance(to: component?.targetPosition ?? .one)
            if distance1 < 0.1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    entity.removeFromParent()
                }
            }
        }
    }
}

func getSeatTileEntity(seat: Int) -> ModelEntity {
    switch seat {
    case 1: return game_seat1
    case 2: return game_seat2
    case 3: return game_seat3
    case 4: return game_seat4
    default: return game_seat1
    }
}
