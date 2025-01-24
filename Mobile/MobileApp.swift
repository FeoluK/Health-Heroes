//
//  MobileApp.swift
//  Mobile
//
//  Created by Hunter Harris on 1/24/25.
//

import SwiftUI

@main
struct MobileApp: App {
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingScreenView()
                    .onAppear {
                        // Simulate loading time then switch to main content
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
