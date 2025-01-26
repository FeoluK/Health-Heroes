//
//  MainView.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//



import Foundation
import SwiftUI
import Combine
import GroupActivities

@available(iOS 17.0, *)
struct MainViewVision: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    @State private var isSharePlayActive = false
    @State var isActivitySharingSheetPresented = false
    @ObservedObject private var gameStateManager = GameStateManager.shared
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack {
            if sharePlayManager.sessionInfo.session != nil {
                PlayerListView()
            } else if groupStateObserver.isEligibleForGroupSession {
                // Not in a session, but is eligible for a session (in Facetime call)
                startSharePlayButton
            } else {
                inviteToSharePlayButton
            }
        }
        // SharePlay share activity sheet handling
        .sheet(isPresented: $isActivitySharingSheetPresented) {
            ActivitySharingViewController2(activity: MyGroupActivity())
        }
    }
    
    var launchCameraButton: some View {
        Button(action: {
            Task { @MainActor in
                GameStateManager.shared.gameState = .inGame
            }
        }) {
            Text("Start")
        }
    }
    
    var startSharePlayButton: some View {
        Button(action: {
            Task { @MainActor in
                sharePlayManager.startSharePlay()
                isSharePlayActive.toggle()
            }
        }) {
            Text(isSharePlayActive ? "Stop SharePlay" : "Start SharePlay")
        }
    }
    
    var inviteToSharePlayButton: some View {
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
                        Text("Invite").foregroundStyle(.white)
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

import UIKit
import GroupActivities

// MARK: - Share Sheet helpers
struct ActivitySharingViewController2: UIViewControllerRepresentable {
    let activity: GroupActivity
    func makeUIViewController(context: Context) -> GroupActivitySharingController {
        return try! GroupActivitySharingController(activity)
    }
    func updateUIViewController(_ uiViewController: GroupActivitySharingController, context: Context) { }
}
