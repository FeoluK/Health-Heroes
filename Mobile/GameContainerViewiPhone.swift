//
//  GameContainerViewiPhone.swift
//  Mobile
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI

struct GameContainerViewiPhone: View {
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
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
                EmptyView()// PlayerListView()
            default:
                EmptyView()
            }
        }
        .onAppear {
            gameStateManager.startLoading()
        }
        .task {
            for await newSession in MyGroupActivity.sessions() {
                SharePlayManager.shared.configureSession(newSession)
            }
        }
    }
}

struct MainView: View {
    var body: some View {
        Text("Game View")
    }
}

struct GameView: View {
    var body: some View {
        Text("Game View")
    }
}
