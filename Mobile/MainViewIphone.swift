//
//  MainView.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 17.0, *)
struct MainViewIphone: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    @State private var isSharePlayActive = false
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    sharePlayManager.startSharePlay()
                    isSharePlayActive.toggle()
                }
            }) {
                Text(isSharePlayActive ? "Stop SharePlay" : "Start SharePlay")
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
