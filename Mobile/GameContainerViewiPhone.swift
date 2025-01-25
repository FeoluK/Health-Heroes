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
    
    @State var isActivitySharingSheetPresented = false
    
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
                
                GameModeManager.shared.loadGame()
                
            case .dismissImmersiveSpace():
                gameStateManager.gameState = .mainMenu
                
            default: return
            }
        })
        // SharePlay share activity sheet handling
        .sheet(isPresented: $isActivitySharingSheetPresented) {
            ActivitySharingViewController(activity: MyGroupActivity())
        }
        
    }
    
    var inviteToSharePlayView: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Invite to  SharePlay").foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 60)
                }
                Spacer()
            }
            
            VStack {
                Button {
                    isActivitySharingSheetPresented = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up").foregroundStyle(.white)
                        Text(LocalizedStringKey("inviteToSharePlayTitle")).foregroundStyle(.white)
                    }
                }
                .padding()
                .buttonStyle(.plain)
                .background(.green)
                .frame(height: 60)
            }
        }
    }
}

struct GameView: View {
    var body: some View {
        Text("Game View")
    }
}

import UIKit
import GroupActivities

// MARK: - Share Sheet helpers
struct ActivitySharingViewController: UIViewControllerRepresentable {
    let activity: GroupActivity
    func makeUIViewController(context: Context) -> GroupActivitySharingController {
        return try! GroupActivitySharingController(activity)
    }
    func updateUIViewController(_ uiViewController: GroupActivitySharingController, context: Context) { }
}
