//
//  BadApplesRealityHackApp.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import SwiftUI

@main
struct BadApplesRealityHackApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            GameContainerViewVision()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

enum Platform {
    case iOS
    case visionOS
    case unknown
}

func currentPlatform() -> Platform {
    #if os(iOS)
    return .iOS
    #elseif os(visionOS)
    return .visionOS
    #else
    return .unknown
    #endif
}
