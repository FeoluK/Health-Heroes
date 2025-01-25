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
        VStack {
            switch gameStateManager.gameState {
            case .loading:
                LoadingScreenView()
            case .mainMenu:
                MainViewIphone()
            case .inGame:
                CameraView()
            case .lobbyIsReady, .lobbyNotReady:
                PlayerListView()
            }
        }
        .onAppear {
            gameStateManager.startLoading()
        }
        .task {
            for await newSession in MyGroupActivity.sessions() {
                SharePlayManager.shared.configureSession(newSession)
                gameStateManager.gameState = .lobbyNotReady
            }
        }
        .onReceive(gameStateManager.sessionActionPublisher, perform: { action in
            switch action {
            case .openImmersiveSpace(let space):
                gameStateManager.gameState = .inGame
                
            case .dismissImmersiveSpace():
                gameStateManager.gameState = .mainMenu
                
            default: return
            }
        })
    }
}

struct GameView: View {
    var body: some View {
        Text("Game View")
    }
}
