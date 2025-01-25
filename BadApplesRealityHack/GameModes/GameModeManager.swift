//
//  GameModeManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation

enum GameMode {
    case ChestCompression
    case mode2
}

class GameModeManager {
    static let shared = GameModeManager()
    
    @Published var gameMode: GameMode = .ChestCompression
    
    public func loadGame() {
        
        switch gameMode {
        case .ChestCompression: retu rn
        case .mode2: return
        default: return
        }
    }
}
