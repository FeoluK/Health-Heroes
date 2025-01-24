//
//  SharePlayManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import GroupActivities

@available(iOS 17.0, *)
class SharePlayManager {
    static let shared = SharePlayManager()
    
    private var groupSession: GroupSession<MyGroupActivity>?
    private var messenger: GroupSessionMessenger?
    
    private init() {
        
    }
    
    func startSharePlay() {
        Task {
            do {
                let activity = MyGroupActivity()
                _ = try await activity.prepareForActivation()
                try await activity.activate()
            } catch {
                print("Failed to start SharePlay: \(error.localizedDescription)")
            }
        }
    }
    
    func joinSharePlay() {
        Task {
            for await session in MyGroupActivity.sessions() {
                configureSession(session)
            }
        }
    }
    
    private func configureSession(_ session: GroupSession<MyGroupActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)
        
        session.join()
        
        session.$state.sink { state in
            switch state {
            case .joined:
                print("Joined SharePlay session")
            case .invalidated:
                print("SharePlay session ended")
                self.cleanup()
            default:
                break
            }
        }.store(in: &session.cancellables)
    }
    
    private func cleanup() {
        groupSession = nil
        messenger = nil
    }
}

// Define your custom GroupActivity
@available(iOS 17.0, *)
struct MyGroupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "My SharePlay Activity"
        metadata.type = .generic
        return metadata
    }
}
