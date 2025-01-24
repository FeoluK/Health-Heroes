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
struct MainView: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    @State private var isSharePlayActive = false
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    switch appModel.immersiveSpaceState {
                        case .open:
                            appModel.immersiveSpaceState = .inTransition
                            await dismissImmersiveSpace()
                            sharePlayManager.cleanup()

                        case .closed:
                            appModel.immersiveSpaceState = .inTransition
                            switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                                case .opened:
                                GameStateManager.shared.gameState = .lobbyNotReady
                                    sharePlayManager.startSharePlay()

                                case .userCancelled, .error:
                                    fallthrough
                                @unknown default:
                                    appModel.immersiveSpaceState = .closed
                            }

                        case .inTransition:
                            break
                    }
                    isSharePlayActive.toggle()
                }
            }) {
                Text(isSharePlayActive ? "Stop SharePlay" : "Start SharePlay")
            }
            .disabled(appModel.immersiveSpaceState == .inTransition)
        }
    }
}
