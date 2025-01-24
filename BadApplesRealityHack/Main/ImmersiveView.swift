//
//  ImmersiveView.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
         
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
