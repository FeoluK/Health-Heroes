//
//  WorldTrackingSessionManager.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/25/25.
//

import Foundation
import SwiftUI
import ARKit
import RealityFoundation

#if os(visionOS)

/// Track the device position in world space
class WorldTrackingSessionManager: ObservableObject {
    static let shared = WorldTrackingSessionManager()
    let session = ARKitSession()
    var ready = false
    let worldTracking = WorldTrackingProvider()
    
    let spaceStartOrigin: simd_float4x4 = .init()
    var currentOffset: simd_float4x4 = .init()

    func startSession() async {
        if WorldTrackingProvider.isSupported {
            do {
                try await session.run([worldTracking])
                ready = true
                await handleWorldTrackingUpdates()
            } catch {
                assertionFailure("Failed to run session: \(error)")
            }
        }
    }

    func stopSession() {
        session.stop()
        ready = false
    }

    func handleWorldTrackingUpdates() async {
//        childAnchor.transform = Transform(matrix: getOriginFromDeviceTransform())
        //latestPose = getOriginFromDeviceTransform()
//        for await update in worldTracking.anchorUpdates {
//        }
    }

    func monitorSessionEvent() async {
//        for await event in session.events {
//
//        }
    }

    func getOriginFromDeviceTransform() -> simd_float4x4 {
        guard let pose = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return simd_float4x4()
        }
        return pose.originFromAnchorTransform
    }
    
    func getPosInfrontOfUser(distance: Float) -> SIMD3<Float> {
        let pose = WorldTrackingSessionManager.shared.getOriginFromDeviceTransform()
        let cameraTransform = Transform(matrix: pose)
        let forwardVector = cameraTransform.rotation.act(simd_float3(0, 0, -1))
        let normalizedForwardVector = normalize(forwardVector)
        var newPosition = cameraTransform.translation + (distance * normalizedForwardVector)
        newPosition += .init(x: 0, y: 0, z: 0)
        return newPosition
    }
}


#else

class WorldTrackingSessionManager: ObservableObject {
    static let shared = WorldTrackingSessionManager()
    
    func getOriginFromDeviceTransform() -> simd_float4x4 {
        return .init()
    }
    
    func getPosInfrontOfUser(distance: Float) -> SIMD3<Float> {
        return .zero
    }
}

#endif
