//
//  PlayerListView.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI

struct PlayerListView: View {
    @ObservedObject private var sharePlayManager = SharePlayManager.shared
    @ObservedObject private var gameStateManager =  GameStateManager.shared

    var body: some View {
        VStack {
            if let _ = sharePlayManager.sessionInfo.session {
                List(gameStateManager.players.keys.sorted(), id: \.self) { key in
                    if let player = gameStateManager.players[key] {
                        HStack {
                            Text(player.name)
                            Spacer()
                            if player.isReady {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                if gameStateManager.players.values.allSatisfy({ $0.isReady }) {
                    playerStartGameButton
                } else {
                    playerReadyButton
                }
            } else {
                Text("No active SharePlay session")
            }
        }
    }
    
    var playerReadyButton: some View {
        Button(action: {
            Player.sendLocalIsReadyMsg()
        }) {
            Text("Ready")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
    
    var playerStartGameButton: some View {
        Button(action: {
            SharePlayManager.sendStartGameMessage()
        }) {
            Text("Start Game")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
