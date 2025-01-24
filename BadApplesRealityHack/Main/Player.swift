//
//  Player.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import GroupActivities

struct PlayerReadyMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    var windowId: String = ""
    var messageId: String = UUID().uuidString
    let id: UUID
    
    static func == (lhs: PlayerReadyMessage, rhs: PlayerReadyMessage) -> Bool {
        lhs.id == rhs.id
    }
}

struct Player: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    var windowId: String = ""
    
    var messageId: String = UUID().uuidString
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name && lhs.id == rhs.id
    }
    
    let name: String
    let id: UUID
    let score: Int
    var isActive: Bool
    
    init(name: String, id: UUID, score: Int, isActive: Bool) {
        self.name = name
        self.score = score
        self.id = id
        self.isActive = isActive
    }
    
    /// The local player, "me".
    static var local: Player? = nil
    
    static func handlePlayerMessage(message: Player,
                                    sender: Participant) async
    {
        var newPlayer = message
        
        Task { @MainActor in
            GameStateManager.shared.players[newPlayer.id] = newPlayer
        }
        if newPlayer.isActive == false {
            GameStateManager.shared.players.removeValue(forKey: newPlayer.id)
        }
        
        if newPlayer.id == Player.local?.id {
            Player.local = newPlayer
        }
    }
}
