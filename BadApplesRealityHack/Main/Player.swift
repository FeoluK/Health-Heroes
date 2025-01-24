//
//  Player.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation

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
    
    init(name: String, id: UUID, score: Int) {
        self.name = name
        self.score = score
        self.id = id
    }
    
    /// The local player, "me".
    static var local: Player? = nil
}
