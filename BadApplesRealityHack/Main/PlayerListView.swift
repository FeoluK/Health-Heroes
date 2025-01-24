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
                List(gameStateManager.players.map { index, participant in
                    "User-\(index))"
                }, id: \ .self) { user in
                    Text(user)
                }
            } else {
                Text("No active SharePlay session")
            }
            
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
    }
}
