//
//  GameContainerViewVision.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation

import SwiftUI

struct GameContainerViewVision: View {
    @StateObject private var gameStateManager = GameStateManager()
    
    var body: some View {
        Group {
            switch gameStateManager.gameState {
            case .loading:
                LoadingScreenView()
            case .mainMenu:
                MainView()
            case .inGame:
                GameView()
            case .lobbyIsReady, .lobbyNotReady:
                PlayerListView()
            default:
                EmptyView()
            }
        }
        .onAppear {
            gameStateManager.startLoading()
        }
    }
}

struct GameView: View {
    var body: some View {
        Text("Game View")
    }
}
