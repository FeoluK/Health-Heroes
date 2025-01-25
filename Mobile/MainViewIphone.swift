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
struct MainViewIphone: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    @State private var isSharePlayActive = false
    @State var isActivitySharingSheetPresented = false
    @ObservedObject private var gameStateManager = GameStateManager.shared
    @StateObject var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack {
            if sharePlayManager.sessionInfo.session != nil {
                
            } else if groupStateObserver.isEligibleForGroupSession {
                // Not in a session, but is eligible for a session (in Facetime call)
                startSharePlayButton
            } else {
                inviteToSharePlayButton
            }
        }
        // SharePlay share activity sheet handling
        .sheet(isPresented: $isActivitySharingSheetPresented) {
            ActivitySharingViewController(activity: MyGroupActivity())
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

//{
//    case .open:
//        appModel.immersiveSpaceState = .inTransition
//        await dismissImmersiveSpace()
//        sharePlayManager.cleanup()
//
//    case .closed:
//        appModel.immersiveSpaceState = .inTransition
//        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
//            case .opened:
//            GameStateManager.shared.gameState = .lobbyNotReady
//                sharePlayManager.startSharePlay()
//
//            case .userCancelled, .error:
//                fallthrough
//            @unknown default:
//                appModel.immersiveSpaceState = .closed
//        }
//
//    case .inTransition:
//        break
//}
