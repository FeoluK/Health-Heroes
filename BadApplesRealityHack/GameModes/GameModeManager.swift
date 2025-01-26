//
//  GameModeManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import RealityFoundation
import RealityKit
import SwiftUICore
import SharePlayMessages

var rootEntity = ModelEntity()
var leftHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [UnlitMaterial(color: .green)])
var rightHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [UnlitMaterial(color: .green)])

var heartRateAnchor = ModelEntity()
var cameraAnchor: ModelEntity = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [UnlitMaterial(color: .green)])
var childAnchor: ModelEntity = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [UnlitMaterial(color: .clear)])

enum GameMode: String {
    case ChestCompression
    case mode2
}

enum GameType: String, CaseIterable, Hashable {
    case CPR = "CPR"
    case xray = "X-Ray Analysis"
    case labTest = "Lab Test"
    case surgery = "Surgery"
    case ultrasound = "Ultrasound"
    case mri = "MRI Scan"
    case cardiology = "Cardiology"
    case neurology = "Neurology"
    case pediatrics = "Pediatrics"
    case emergency = "Emergency"
    case dental = "Dental"
    case ophthalmology = "Eye Care"
    case dermatology = "Skin Care"
    case orthopedics = "Orthopedics"
    case psychology = "Psychology"
    
    var icon: String {
        switch self {
        case .CPR: return "heart.circle.fill"
        case .xray: return "rays"
        case .labTest: return "flask.fill"
        case .surgery: return "cross.case.fill"
        case .ultrasound: return "waveform"
        case .mri: return "brain.head.profile"
        case .cardiology: return "heart.fill"
        case .neurology: return "brain"
        case .pediatrics: return "figure.child"
        case .emergency: return "bolt.heart.fill"
        case .dental: return "mouth.fill"
        case .ophthalmology: return "eye.fill"
        case .dermatology: return "hand.raised.fill"
        case .orthopedics: return "figure.walk"
        case .psychology: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .CPR: return .red
        case .xray: return .purple
        case .labTest: return .blue
        case .surgery: return .green
        case .ultrasound: return .cyan
        case .mri: return .orange
        case .cardiology: return .pink
        case .neurology: return .indigo
        case .pediatrics: return .yellow
        case .emergency: return .red
        case .dental: return .mint
        case .ophthalmology: return .teal
        case .dermatology: return .brown
        case .orthopedics: return .gray
        case .psychology: return .purple
        }
    }
}

class GameModeManager {
    static let shared = GameModeManager()
    
    @Published var gameMode: GameMode = .ChestCompression
    
    public func handleSceneUpdate() {
        switch self.gameMode {
        case .ChestCompression: return
        case .mode2: return
        }
    }
    
    public func loadGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            switch self.gameMode {
            case .ChestCompression: Scene_ChestCompression.configureScene()
            case .mode2: return
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

class Scene_ChestCompression: ObservableObject {
    static let shared = Scene_ChestCompression()
    
    @Published var currentHeartRate = 80
    
    private var heartRateTimer: Timer?
    
    deinit {
        heartRateTimer?.invalidate()
    }
    
    static func configureScene() {
        configureFloorTiles()
        
        if currentPlatform() == .iOS {
            configureSpherePumper()
        }
    }
    
    func startTimer() {
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.currentHeartRate = min((self?.currentHeartRate ?? 0) + 20, 160)
        }
    }
    
    static func configureSpherePumper() {
        chestSphere1 = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        chestSphere1.position = getSeatTileEntity(seat: Player.local?.playerSeat ?? 1).position(relativeTo: nil)
        chestSphere1.position.y = childAnchor.position(relativeTo: nil).y
        chestSphere1.position.y += 0.3
        rootEntity.addChild(chestSphere1)

        chestSphere1.components[ScalingComponent.self] = ScalingComponent(targetEntity: childAnchor)
    }
    
    static func configureFloorTiles() {
        let floorHeight: Float = currentPlatform() == .visionOS ? 0 : -1.2
        game_seat1 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 1), isMetallic: true)])
        rootEntity.addChild(game_seat1)
        game_seat1.position = .init(x: 0, y: floorHeight, z: -1)
        
        game_seat2 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 2), isMetallic: true)])
        rootEntity.addChild(game_seat2)
        game_seat2.position = .init(x: -0.9, y: floorHeight, z: 0)
        
        game_seat3 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 3), isMetallic: true)])
        rootEntity.addChild(game_seat3)
        game_seat3.position = .init(x: 0, y: floorHeight, z: 0)
        
        game_seat4 = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SharePlayManager.getColorForSeat(seat: 4), isMetallic: true)])
        rootEntity.addChild(game_seat4)
        game_seat4.position = .init(x: 0.9, y: floorHeight, z: 0)
    }
    
    static func handleSceneUpdate() {
    }
}

struct ScalingComponent: Component {
    var targetEntity: Entity
    var scaleFactor: Float = 30
    
    public init(targetEntity: Entity, scaleFactor: Float = 30) {
        self.targetEntity = targetEntity
        self.scaleFactor = scaleFactor
    }
}

class ScalingSystem: System {
    private var pumpCounter: Int = 0
    private var lastPumpTime: Date?
    private var lastSuccessPumpTime: Date?
    private let requiredPumps: Int = 3
    private let timeLimit: TimeInterval = 0.3
    private let pumpCooldown: TimeInterval = 3.0

    required init(scene: RealityKit.Scene) { }

    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(
            EntityQuery(where: .has(ScalingComponent.self))
        )

        for entity in entities {
            guard let scalingComponent = entity.components[ScalingComponent.self] else {
                continue
            }

            if let lastSuccessPumpTime {
                guard Date().timeIntervalSince(lastSuccessPumpTime) >= pumpCooldown else { continue }
            }
            
            let distance = entity.position.distance(to: childAnchor.position(relativeTo: nil))

            print("child anchor pos: \(childAnchor.position(relativeTo: nil))")
            print("distance: \(distance)")
            if distance <= 0.1 {
                if let lastTime = lastPumpTime, Date().timeIntervalSince(lastTime) <= timeLimit {
                    pumpCounter += 1
                } else {
                    pumpCounter = 1
                }
                lastPumpTime = Date()

                if pumpCounter >= requiredPumps {
                    lastSuccessPumpTime = Date()
                    print("Successful pump actions completed!")
                    pumpCounter = 0
                    lastPumpTime = Date()
                    
                    if var player = Player.local {
                        player.score += 1
                        SharePlayManager.sendMessage(message: player)
                    }
                    
                    // Play success sound
                    AudioManager.shared.playSound(
                        named: SoundEffect.success.rawValue,
                        volume: 0.3
                    )
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        entity.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        entity.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
                    }
                    
                    SharePlayManager.sendMessage(message: Game_SendHeartMessage(windowId: "", messageId: "", id: UUID(), seatNumber: Player.local?.playerSeat ?? 0, heartHeight: childAnchor.position(relativeTo: nil).y + 0.2), handleLocally: true)
                }
            }

            if let lastTime = lastPumpTime, Date().timeIntervalSince(lastTime) > timeLimit {
                pumpCounter = 0
            }
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
