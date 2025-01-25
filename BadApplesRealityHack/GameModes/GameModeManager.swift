//
//  GameModeManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import RealityFoundation

var rootEntity = ModelEntity()

enum GameMode: String {
    case ChestCompression
    case mode2
}

class GameModeManager {
    static let shared = GameModeManager()
    
    @Published var gameMode: GameMode = .ChestCompression
    
    public func loadGame() {
        
        switch gameMode {
        case .ChestCompression: return
        case .mode2: return
        default: return
        }
    }
}
