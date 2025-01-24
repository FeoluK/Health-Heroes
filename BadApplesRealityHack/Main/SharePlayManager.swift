//
//  SharePlayManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import GroupActivities
import Combine

@available(iOS 17.0, *)

var sessionInfo: DemoSessionInfo = .init()

class SharePlayManager: ObservableObject {
    static let shared = SharePlayManager()
    
    var groupSession: GroupSession<MyGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func startSharePlay() {
        Task {
            do {
                let activity = MyGroupActivity()
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
    
    func configureSession(_ session: GroupSession<MyGroupActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)
        
        session.join()
        
        session.$state.sink { [weak self] state in
            switch state {
            case .waiting: self?.joinSharePlay()
            case .joined:
                self?.configureAfterJoining()
            case .invalidated:
                print("SharePlay session ended")
                self?.cleanup()
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    func configureAfterJoining() {
        
    }
    
    static func subscribeToSessionUpdates() {
        if let messenger =  sessionInfo.messenger {
            var task = Task { @MainActor in
                for await (anyMessage, sender) in messenger.messages(of: AnySharePlayMessage.self) {
                    await SharePlayManager.handleMessage(anyMessage, sender: sender.source)
                }
            }
        }
    }
    
    /// Handle individual AnySharePlayMessage messages
    @MainActor
    static func handleMessage(_ message: AnySharePlayMessage,
                              sender: Participant,
                              forceHandling: Bool = false) async {
        switch message.base {
        case let message as Player:
            return
        case let message as PlayerReadyMessage:
            return
        default: return
        }
    }
    
    func cleanup() {
        groupSession = nil
        messenger = nil
        cancellables.removeAll()
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
    static var activityIdentifier = "dicyaninlabs.org.shareplay-activity2"
}


class DemoSessionInfo: ObservableObject {
    @Published var session: GroupSession<MyGroupActivity>?
    @Published var messenger: GroupSessionMessenger?
    var reliableMessenger: GroupSessionMessenger?
    var journal: GroupSessionJournal?
    
    init() { }
    init(newSession: GroupSession<MyGroupActivity>) {
        Task { @MainActor in
            configureForSession(newSession: newSession)
        }
    }
    
    @MainActor
    func configureForSession(newSession: GroupSession<MyGroupActivity>) {
        sessionInfo.session = newSession
        sessionInfo.messenger = GroupSessionMessenger(session: newSession, deliveryMode: .reliable)
        sessionInfo.reliableMessenger = GroupSessionMessenger(session: newSession, deliveryMode: .unreliable)
    }
}

// MARK: - Messages

protocol SharePlayMessage: Codable, Equatable, Decodable {
    var windowId: String { get }
    var messageId: String { get }
}

/// Generic SharePlayMessage type with custom decoding & encoding.
struct AnySharePlayMessage: Codable {
    let base: any SharePlayMessage

    init<T: SharePlayMessage>(_ base: T) {
        self.base = base
    }

    private enum CodingKeys: String, CodingKey {
        case base
        case type
    }

    private enum MessageType: String, Codable {
        case playerMessage
        case playerReadyMessage
       
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch base {
        case is Player:
            try container.encode(MessageType.playerMessage, forKey: .type)
        case is PlayerReadyMessage:
            try container.encode(MessageType.playerReadyMessage, forKey: .type)
        default:
            throw EncodingError.invalidValue(base, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Error encoding AnySharePlayMessage: Invalid type"))
        }
        
        let data = try JSONEncoder().encode(base)
        try container.encode(data, forKey: .base)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        let data = try container.decode(Data.self, forKey: .base)

        switch type {
        case .playerMessage:
            base = try JSONDecoder().decode(Player.self, from: data)
            
        case .playerReadyMessage:
            base = try JSONDecoder().decode(PlayerReadyMessage.self, from: data)
        default: return
        }
    }
}




