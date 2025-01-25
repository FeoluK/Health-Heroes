import SwiftUI
import RealityFoundation
import Combine
import GroupActivities

enum SessionAction {
    case openImmersiveSpace(String)
    case dismissImmersiveSpace(Void)
}

class GameStateManager: ObservableObject {
    
    static let shared = GameStateManager()
    
    @Published var isLoading = true
    @Published var gameState: GameState = .loading
    
    @Published var players: [UUID: Player] = [:]
    
    var tasks = Set<Task<Void, Never>>()
    var sharePlayMessages: [any SharePlayMessage] = []
    
    let actionSubject = PassthroughSubject<SessionAction, Never>()
    var sessionActionPublisher: AnyPublisher<SessionAction, Never> { actionSubject.eraseToAnyPublisher() }
    
    enum GameState {
        case loading
        case mainMenu
        case inGame
        case lobbyIsReady
        case lobbyNotReady
    }
    
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
            if currentPlatform() == .visionOS {
                let newHeart = ModelEntity()
                newHeart.position = getSeatTileEntity(seat: message.seatNumber).position
                
                rootEntity.addChild(newHeart)
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
