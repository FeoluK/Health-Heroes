//
//  GameContainerViewVision.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI

struct GameContainerViewVision: View {
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some View {
        Group {
            switch gameStateManager.gameState {
            case .loading:
                LoadingScreenView()
            case .mainMenu:
                MainView()
            case .inGame:
                GameViewVision()
            case .lobbyIsReady, .lobbyNotReady:
                PlayerListView()
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
#if os(visionOS)
        // Open the ImmersiveSpace when we receive .openImmersiveSpace from sessionActionPublisher
        .onReceive(gameStateManager.sessionActionPublisher, perform: { action in
            switch action {
            case .openImmersiveSpace(let space):
                Task { @MainActor in
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
                
            case .dismissImmersiveSpace():
                Task { @MainActor in
                    await dismissImmersiveSpace()
                }
            default: return
            }
        })
#endif
        
    }
}
//
//struct GameView: View {
//    var body: some View {
//        Text("Game View")
//    }
//}

struct GameViewVision: View {
    var body: some View {
        Text("Game View")
    }
}


