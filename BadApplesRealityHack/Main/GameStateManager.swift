import SwiftUI

class GameStateManager: ObservableObject {
    
    static let shared = GameStateManager()
    
    @Published var isLoading = true
    @Published var gameState: GameState = .loading
    
    @Published var players: [UUID: Player] = [:]
    
    var tasks = Set<Task<Void, Never>>()
    var sharePlayMessages: [any SharePlayMessage] = []
    
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
} 
