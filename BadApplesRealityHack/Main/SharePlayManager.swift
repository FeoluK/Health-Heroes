//
//  SharePlayManager.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import GroupActivities
import Combine
import SwiftUICore
import UIKit

@available(iOS 17.0, *)


class SharePlayManager: ObservableObject {
    static let shared = SharePlayManager()
    
    
    @Published var sessionInfo: DemoSessionInfo = .init()
    
//    var groupSession: GroupSession<MyGroupActivity>?
//    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func startSharePlay() {
        Task {
            do {
                let activity = MyGroupActivity()
                let _ = try await activity.activate()
            } catch {
                print("Failed to start SharePlay: \(error.localizedDescription)")
            }
        }
    }
    
    func configureSession(_ session: GroupSession<MyGroupActivity>) {
        self.cleanup()
        
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1000000000)
            joinSession(session: session)
        }
        
        session.$state.sink { [weak self] state in
            switch state {
            case .invalidated: self?.cleanup()
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    func joinSession(session:  GroupSession<MyGroupActivity>) {
        Task { @MainActor in
            sessionInfo = .init(newSession: session)
            GameStateManager.shared.gameState = .lobbyNotReady
            
            SharePlayManager.subscribeToSessionUpdates()
            SharePlayManager.subscribeToPlayerUpdates()
            
            SharePlayManager.shared.sessionInfo.session?.join()
            GameStateManager.shared.gameState = .lobbyNotReady
        }
    }
    
    static func subscribeToSessionUpdates() {
        if let messenger = SharePlayManager.shared.sessionInfo.messenger {
            var task = Task { @MainActor in
                for await (anyMessage, sender) in messenger.messages(of: AnySharePlayMessage.self) {
                    await SharePlayManager.handleMessage(anyMessage, sender: sender.source)
                }
            }
            GameStateManager.shared.tasks.insert(task)
        }
    }
    
    static func subscribeToPlayerUpdates() {
        guard let newSession = SharePlayManager.shared.sessionInfo.session else {
            print("failed to get session"); return }
        
        newSession.$activeParticipants.sink { activeParticipants in
            let localId = newSession.localParticipant.id
            var totalParticipants = activeParticipants.count
            if totalParticipants == 1 {
                totalParticipants += 1
            }
            let isVisionDevice = currentPlatform() == .visionOS
            Player.local = .init(name: "name", id: localId, score: 0, isActive: true, isReady: false, isVisionDevice: isVisionDevice, playerSeat: isVisionDevice ? 1 : totalParticipants) // todo: fix player seat Id
            GameStateManager.shared.players[localId] = Player.local
            
            for participant in activeParticipants {
                let potentialNewPlayer = Player(name: "name", id: participant.id, score: 0, isActive: true, isReady: false, isVisionDevice: false, playerSeat: 0)
                
                if !GameStateManager.shared.players.values.contains(where: { $0.id == potentialNewPlayer.id })
                {
                    let task = Task { @MainActor in
                        Player.sendLocalPlayerUpdateMsg()
                        GameStateManager.shared.players[participant.id] = potentialNewPlayer
                    }
                    GameStateManager.shared.tasks.insert(task)
                }
            }
        }
        .store(in: &SharePlayManager.shared.cancellables)
    }
    
    static func getColorForSeat(seat: Int) -> UIColor {
        switch seat {
        case 1: return .red
        case 2: return .blue
        case 3: return .purple
        case 4: return .yellow
        default: return .black
        }
    }
    
    /// Handle individual AnySharePlayMessage messages
    @MainActor
    static func handleMessage(_ message: AnySharePlayMessage,
                              sender: Participant,
                              forceHandling: Bool = false) async {
        switch message.base {
        case let message as Player:
            await Player.handlePlayerMessage(message: message, sender: sender)
        case let message as PlayerReadyMessage:
            return
        case let message as Game_StartMessage:
           await GameStateManager.handleGameStartMsg(message: message, sender: sender)
        case let message as Game_SendHeartMessage:
           await GameStateManager.handleHeartMessage(message: message, sender: sender)
        default: return
        }
    }
    
    static func sendMessage(message: any SharePlayMessage,
                            participants: Set<Participant>? = nil,
                            sendShimmer: Bool = true,
                            updateStoreage: Bool = true,
                            handleLocally: Bool = false)
    {
        if handleLocally {
            Task {
                if let localParticipant = SharePlayManager.shared.sessionInfo.session?.localParticipant {
                    await SharePlayManager.handleMessage(AnySharePlayMessage(message), sender: localParticipant, forceHandling: handleLocally)
                }
            }
        }
    
        if let session = SharePlayManager.shared.sessionInfo.session,
            let messenger = SharePlayManager.shared.sessionInfo.messenger
        {
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])
            let newMessage = AnySharePlayMessage(message)
            messenger.send(newMessage, to: .only(participants ?? everyoneElse)) { error in
                if let error = error { print("Error sending \(message.self) Message: \(error)") }
            }
        }
    }
    
    func cleanup() {
        SharePlayManager.shared.sessionInfo.session = nil
        sessionInfo.session = nil
        sessionInfo.messenger = nil
        sessionInfo = .init()
        cancellables.removeAll()
        GameStateManager.shared.gameState = .mainMenu
    }
}

extension SharePlayManager {
    static func sendStartGameMessage() {
        let startGameMsg: Game_StartMessage = .init(id: UUID(), gameMode: GameModeManager.shared.gameMode.rawValue)
        sendMessage(message: startGameMsg, handleLocally: true)
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
        self.session = newSession
        self.messenger = GroupSessionMessenger(session: newSession, deliveryMode: .reliable)
        self.reliableMessenger = GroupSessionMessenger(session: newSession, deliveryMode: .unreliable)
        Task { @MainActor in
            SharePlayManager.shared.sessionInfo = self
        }
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
        case game_StartMessage
        case game_SendHeartMessage
       
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch base {
        case is Player:
            try container.encode(MessageType.playerMessage, forKey: .type)
        case is PlayerReadyMessage:
            try container.encode(MessageType.playerReadyMessage, forKey: .type)
        case is Game_StartMessage:
            try container.encode(MessageType.game_StartMessage, forKey: .type)
        case is Game_SendHeartMessage:
            try container.encode(MessageType.game_SendHeartMessage, forKey: .type)
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
        case .game_StartMessage:
            base = try JSONDecoder().decode(Game_StartMessage.self, from: data)
        case .game_SendHeartMessage:
            base = try JSONDecoder().decode(Game_SendHeartMessage.self, from: data)
        default: return
        }
    }
}





struct Game_StartMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    var windowId: String = ""
    var messageId: String = UUID().uuidString
    let id: UUID
    let gameMode: String
    
    static func == (lhs: Game_StartMessage, rhs: Game_StartMessage) -> Bool {
        lhs.id == rhs.id
    }
}


struct Game_SendHeartMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    var windowId: String = ""
    var messageId: String = UUID().uuidString
    let id: UUID
    let seatNumber: Int
    let heartHeight: Float
    
    static func == (lhs: Game_SendHeartMessage, rhs: Game_SendHeartMessage) -> Bool {
        lhs.id == rhs.id
    }
}
