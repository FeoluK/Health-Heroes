//
//  PlayerListView.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI

struct PlayerListView: View {
    @ObservedObject private var sharePlayManager = SharePlayManager.shared

    var body: some View {
        VStack {
            if let session = sessionInfo.session {
                List(session.activeParticipants.enumerated().map { index, participant in
                    "User\(index + 1))"
                }, id: \ .self) { user in
                    Text(user)
                }
            } else {
                Text("No active SharePlay session")
            }
            
            Button(action: {
                // Empty hook for button action
            }) {
                Text("Ready")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}
