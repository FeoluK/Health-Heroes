//
//  MobileApp.swift
//  Mobile
//
//  Created by Hunter Harris on 1/24/25.
//

import SwiftUI

@main
struct MobileApp: App {
    
    init() {
        ScalingSystem.registerSystem()
        ScalingComponent.registerComponent()
        ProximityComponent.registerComponent()
        ProximitySystem.registerSystem()
        
        HeartMovementSystem.registerSystem()
        HeartMovementComponent.registerComponent()
    }
    var body: some Scene {
        WindowGroup {
            GameContainerViewiPhone()
        }
    }
}
