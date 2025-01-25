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
        case .ChestCompression: return
//            Scene_ChestCompression.handleSceneUpdate()
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

var game_seat1 = ModelEntity()
var game_seat2 = ModelEntity()
var game_seat3 = ModelEntity()
var game_seat4 = ModelEntity()

class Scene_ChestCompression {
    
    static func configureScene() {
        configureFloorTiles()
        
        chestSphere1 = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere1)
        
        chestSphere2 = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        rootEntity.addChild(chestSphere2)
        chestSphere2.position = devicePositionAnchor.position
        chestSphere2.position.x += -0.09
        
        // Add ScalingComponent to spheres
        chestSphere1.components[ScalingComponent.self] = ScalingComponent(targetEntity: childAnchor)
        chestSphere2.components[ScalingComponent.self] = ScalingComponent(targetEntity: childAnchor)
        
        // Add ProximityComponent to spheres
//        chestSphere1.components[ProximityComponent.self] = ProximityComponent(targetEntity: childAnchor)
//        chestSphere2.components[ProximityComponent.self] = ProximityComponent(targetEntity: childAnchor)
    }
    
    static func configureFloorTiles() {
        game_seat1 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 1), isMetallic: true)])
        rootEntity.addChild(game_seat1)
        game_seat1.position = .init(x: 0, y: -0.3, z: -1)
        
        game_seat2 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 2), isMetallic: true)])
        rootEntity.addChild(game_seat2)
        game_seat2.position = .init(x: -0.6, y: -0.3, z: 0)
        
        game_seat3 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 3), isMetallic: true)])
        rootEntity.addChild(game_seat3)
        game_seat3.position = .init(x: 0, y: -0.3, z: 0)
        
        game_seat4 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 4), isMetallic: true)])
        rootEntity.addChild(game_seat4)
        game_seat4.position = .init(x: 0.6, y: -0.3, z: 0)
        
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
    var scaleFactor: Float = 30
    
    public init(targetEntity: Entity, scaleFactor: Float = 30) {
        self.targetEntity = targetEntity
        self.scaleFactor = scaleFactor
    }
}

class ScalingSystem: System {
    required init(scene: RealityKit.Scene) {
        
    }

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
            let distance = entity.position.distance(to: childAnchor.position)
            
            // Define a scaling factor based on distance
            let scaleFactor = max(0.1, 1.0 + distance)
            
            // Apply the scaling factor to the entity
            entity.scale = SIMD3<Float>(repeating: scaleFactor)
        }
    }
}

// Component to handle proximity logic
struct ProximityComponent: Component {
    var targetEntity: Entity
    var proximityFactor: Float = 1.0
    
    public init(targetEntity: Entity, proximityFactor: Float = 1.0) {
        self.targetEntity = targetEntity
        self.proximityFactor = proximityFactor
    }
}

final class ProximitySystem: System {
    required init(scene: RealityKit.Scene) { }

    func update(context: SceneUpdateContext) {
        // Query entities with the ProximityComponent
        let entities = context.scene.performQuery(
            EntityQuery(where: .has(ProximityComponent.self))
        )

        for entity in entities {
            guard let proximityComponent = entity.components[ProximityComponent.self] else {
                continue
            }
            
            // Calculate distance to target entity
            let distance = entity.position.distance(to: childAnchor.position)
            
            // Adjust position to move closer based on distance
            let moveFactor = max(0.1, 1.0 - distance * proximityComponent.proximityFactor)
            entity.position.x += moveFactor * (proximityComponent.targetEntity.position.x - entity.position.x)
            entity.position.y += moveFactor * (proximityComponent.targetEntity.position.y - entity.position.y)
            entity.position.z += moveFactor * (proximityComponent.targetEntity.position.z - entity.position.z)
        }
    }
}


enum Platform {
    case iOS
    case visionOS
    case unknown
}

func currentPlatform() -> Platform {
    #if os(iOS)
    return .iOS
    #elseif os(visionOS)
    return .visionOS
    #else
    return .unknown
    #endif
}
