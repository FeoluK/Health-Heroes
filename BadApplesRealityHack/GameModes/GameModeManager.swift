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
        case .ChestCompression: Scene_ChestCompression.configureScene()
        case .mode2: return
        default: return
        }
    }
}



class Scene_ChestCompression {
    
    static func configureScene() {
        let sphere1 = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(sphere1)
        
        let sphere2 = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(sphere2)
        sphere2.position = devicePositionAnchor.position
        sphere2.position.x += -0.18
    }
    
    static func handleSceneUpdate() {
        
    }
}
