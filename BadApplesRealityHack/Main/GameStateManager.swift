import SwiftUI

class GameStateManager: ObservableObject {
    @Published var isLoading = true
    @Published var gameState: GameState = .loading
    
    enum GameState {
        case loading
        case mainMenu
        case inGame
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
