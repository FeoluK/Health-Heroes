//
//  PlayerListView.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI
import SharePlayMessages

struct PlayerListView: View {
    @ObservedObject private var sharePlayManager = SharePlayManager.shared
    @ObservedObject private var gameStateManager = GameStateManager.shared
    
    // Animation states
    @State private var orbitAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var titleOffset: CGFloat = -50
    @State private var titleOpacity: Double = 0
    
    // Orbiting symbols for background
    let orbitingSymbols = [
        ("cross.case.fill", 120.0, 0.0),    // symbol, radius, phase
        ("heart.fill", 160.0, 72.0),
        ("syringe.fill", 120.0, 144.0),
        ("bandage.fill", 160.0, 216.0),
        ("pills.fill", 120.0, 288.0)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FF6B6B"),
                                            Color(hex: "4ECDC4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                ForEach(orbitingSymbols.indices, id: \.self) { index in
                    let symbol = orbitingSymbols[index]
                    let center = CGPoint(x: geometry.size.width/2, y: 150)
                    let angle = orbitAngle + symbol.2
                    let x = center.x + cos(angle * .pi/180) * symbol.1
                    let y = center.y + sin(angle * .pi/180) * (symbol.1 * 0.4)
                    
                    Image(systemName: symbol.0)
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                        .position(x: x, y: y)
                        .scaleEffect(pulseScale)
                }
            }
            
            VStack(spacing: 25) {
                Text("Medical Team")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                
                if let _ = sharePlayManager.sessionInfo.session {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(gameStateManager.players.keys.sorted().enumerated()), id: \.element) { index, key in
                                if let player = gameStateManager.players[key] {
                                    PlayerCard(player: player, delay: Double(index) * 0.2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    if gameStateManager.players.values.allSatisfy({ $0.isReady }) {
                        playerStartGameButton
                    } else {
                        playerReadyButton
                    }
                } else {
                    Text("No active SharePlay session")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            withAnimation(.spring(duration: 1.0)) {
                titleOffset = 0
                titleOpacity = 1
            }
        }
    }
    
    var playerReadyButton: some View {
        Button(action: {
            PlayerFuncs.sendLocalIsReadyMsg()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Ready")
            }
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        colors: [Color(hex: "FF6B6B"), Color(hex: "FFE66D")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    var playerStartGameButton: some View {
        Button(action: {
            SharePlayManager.sendStartGameMessage()
            GameStateManager.shared.actionSubject.send(.openImmersiveSpace("ImmersiveSpace"))
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Game")
            }
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        colors: [Color(hex: "4ECDC4"), Color(hex: "FFE66D")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}

struct PlayerCard: View {
    let player: Player
    let delay: Double
    @State private var offset: CGFloat = 500
    @State private var opacity: Double = 0
    @State private var readyPulse: CGFloat = 1.0
    @State private var isEditing = false
    @State private var newName = ""
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(SharePlayManager.getColorForSeat(seat: player.playerSeat)))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: Color(SharePlayManager.getColorForSeat(seat: player.playerSeat)).opacity(0.5), radius: 5)
                
                Text(String(player.playerSeat))
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            if player.isReady {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
                    .scaleEffect(readyPulse)
                    .shadow(color: .green.opacity(0.5), radius: 5)
                    .zIndex(10)
                    .padding(.trailing, 30)
            }
            
            if isEditing && player.id == Player.local?.id {
                TextField("Enter name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                    .frame(width: 120)
                    .onSubmit {
                        if !newName.isEmpty {
                            //Player.sendNameUpdateMsg(newName: newName)
                            isEditing = false
                        }
                    }
            } else {
                Text(player.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .onTapGesture {
                        if player.id == Player.local?.id {
                            isEditing = true
                            newName = player.name
                        }
                    }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
//                if player.id == Player.local?.id && !isEditing {
//                    Image(systemName: "pencil.circle.fill")
//                        .foregroundColor(.white.opacity(0.8))
//                        .font(.system(size: 24))
//                        .onTapGesture {
//                            isEditing = true
//                            newName = player.name
//                        }
//                }
                
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.15))
                .shadow(color: .black.opacity(0.1), radius: 5)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .offset(x: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.4).delay(delay)) {
                offset = 0
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                readyPulse = 1.2
            }
        }
    }
}

#Preview {
    PlayerListView()
}

#Preview {
    PlayerListView()
}
