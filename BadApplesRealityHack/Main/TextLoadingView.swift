//
//  TextLoadingView.swift
//  BadApples
//
//  Created by Feolu Kolawole on 1/24/25.
//

import SwiftUI
import RealityKit

struct TextLoadingView: View {
    @State private var countdownNumber = 3
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 2
    @State private var rotation: Double = 0
    
    var body: some View {
        if #available(iOS 18.0, *) {
            RealityView { content in
                content.camera = .spatialTracking
                
            } update: { content in
                
            }.ignoresSafeArea()
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    TextLoadingView()
}
