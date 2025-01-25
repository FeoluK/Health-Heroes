//
//  GameModeManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import RealityFoundation
import RealityKit

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
        chestSphere1 = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere1)
        
        chestSphere2 = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere2)
        chestSphere2.position = devicePositionAnchor.position
        chestSphere2.position.x += -0.09
        
        // Add ScalingComponent to spheres
        chestSphere1.components[ScalingComponent.self] = ScalingComponent(targetEntity: devicePositionAnchor)
        chestSphere2.components[ScalingComponent.self] = ScalingComponent(targetEntity: devicePositionAnchor)
    }
    
    static func handleSceneUpdate() {
//        let distance1 = chestSphere1.position.distance(to: devicePositionAnchor.position)
//        let distance2 = chestSphere2.position.distance(to: devicePositionAnchor.position)
//        
//        // Define a scaling factor based on distance
//        let scaleFactor1 = max(0.1, 1.0 - distance1)
//        let scaleFactor2 = max(0.1, 1.0 - distance2)
//        
//        // Apply the scaling factor to the spheres
//        chestSphere1.scale = SIMD3<Float>(repeating: scaleFactor1)
//        chestSphere2.scale = SIMD3<Float>(repeating: scaleFactor2)
    }
}

// Component to handle scaling based on distance
struct ScalingComponent: Component {
    var targetEntity: Entity
    var scaleFactor: Float = 1.8
    
    public init(targetEntity: Entity, scaleFactor: Float = 1.9) {
        self.targetEntity = targetEntity
        self.scaleFactor = scaleFactor
    }
}

class ScalingSystem: System {
    required init(scene: RealityKit.Scene) { }

    func update(context: SceneUpdateContext) {
        // Query entities with the ScalingComponent
        let entities = context.scene.performQuery(
            EntityQuery(where: .has(ScalingComponent.self))
        )

        for entity in entities {
            guard let scalingComponent = entity.components[ScalingComponent.self] else {
                continue
            }
            
            // Calculate distance to target entity
            let distance = entity.position.distance(to: scalingComponent.targetEntity.position)
            
            // Define a scaling factor based on distance
            let scaleFactor = max(0.1, 1.0 - distance)
            
            // Apply the scaling factor to the entity
            entity.scale = SIMD3<Float>(repeating: scaleFactor)
        }
    }
}


// Usage
// Assuming `scene` is your RealityKit scene
// scene.addScalingSystem(targetEntity: devicePositionAnchor)
