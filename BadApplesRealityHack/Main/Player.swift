//
//  Player.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import SharePlayMessages
import GroupActivities


class PlayerFuncs {
    
    static func sendLocalPlayerUpdateMsg() {
        if var updatedPlayerMsg = Player.local {
            SharePlayManager.sendMessage(message: updatedPlayerMsg)
        }
    }
    
    static func sendLocalIsReadyMsg() {
        if var updatedPlayerMsg = Player.local {
            updatedPlayerMsg.isReady = true
            SharePlayManager.sendMessage(message: updatedPlayerMsg, handleLocally: true)
        }
    }
    
    public static func handlePlayerMessage(message: Player,
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
        
//        GameStateManager.shared.configurePlayerSeats()
    }
}
