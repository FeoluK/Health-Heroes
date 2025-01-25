import SwiftUI
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
}
