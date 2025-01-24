//
//  GameContainerViewVision.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation

import SwiftUI

struct GameContainerViewiPhone: View {
    @StateObject private var gameStateManager = GameStateManager()
    
    var body: some View {
        Group {
            switch gameStateManager.gameState {
            case .loading:
                LoadingScreenView()
            case .mainMenu:
                MainMenuView()
            case .inGame:
                GameView()
            }
        }
        .onAppear {
            gameStateManager.startLoading()
        }
    }
}

// Placeholder views - you'll implement these later
struct MainMenuView: View {
    var body: some View {
        Text("Main Menu")
    }
}

struct GameView: View {
    var body: some View {
        Text("Game View")
    }
}
