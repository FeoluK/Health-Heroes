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
    
    var body: some View {
        VStack {
            Button(action: {
                if isSharePlayActive {
                    // Logic to stop SharePlay
                    sharePlayManager.cleanup()
                } else {
                    // Logic to start SharePlay
                    sharePlayManager.startSharePlay()
                }
                isSharePlayActive.toggle()
            }) {
                Text(isSharePlayActive ? "Stop SharePlay" : "Start SharePlay")
            }
        }
    }
}
