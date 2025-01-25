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
    
    public func handleSceneUpdate() {
        switch self.gameMode {
        case .ChestCompression:
            Scene_ChestCompression.handleSceneUpdate()
        case .mode2: return
        }
    }
    
    public func loadGame() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            switch self.gameMode {
            case .ChestCompression: Scene_ChestCompression.configureScene()
            case .mode2: return
            default: return
            }
        }
    }
}

var chestSphere1 = ModelEntity()
var chestSphere2 = ModelEntity()

class Scene_ChestCompression {
    
    static func configureScene() {
        chestSphere1 = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere1)
        
        chestSphere2 = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere2)
        chestSphere2.position = devicePositionAnchor.position
        chestSphere2.position.x += -0.18
    }
    
    static func handleSceneUpdate() {
        let distance1 = chestSphere1.position.distance(to: devicePositionAnchor.position)
        let distance2 = chestSphere2.position.distance(to: devicePositionAnchor.position)
        
        // Define a scaling factor based on distance
        let scaleFactor1 = max(0.1, 1.0 - distance1)
        let scaleFactor2 = max(0.1, 1.0 - distance2)
        
        // Apply the scaling factor to the spheres
        chestSphere1.scale = SIMD3<Float>(repeating: scaleFactor1)
        chestSphere2.scale = SIMD3<Float>(repeating: scaleFactor2)
    }
}
