//
//  MainView.swift
//  BadApples
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import SwiftUI
import Combine
import GroupActivities

@available(iOS 17.0, *)
struct MainViewIphone: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    @State private var isSharePlayActive = false
    @State var isActivitySharingSheetPresented = false
    @ObservedObject private var gameStateManager = GameStateManager.shared
    @StateObject var groupStateObserver = GroupStateObserver()
    
    // Animation states
    @State private var rotation: Double = 0
    @State private var floatingSymbols: [(String, CGPoint, Double)] = [
        ("cross.case.fill", CGPoint(x: 50, y: 100), 0),
        ("heart.fill", CGPoint(x: 300, y: 150), 45),
        ("brain.head.profile", CGPoint(x: 150, y: 200), 90),
        ("lungs.fill", CGPoint(x: 250, y: 50), 180),
        ("pill.fill", CGPoint(x: 100, y: 300), 270),
        ("stethoscope", CGPoint(x: 200, y: 250), 135)
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FF6B6B"), Color(hex: "4ECDC4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Top section for floating symbols
            VStack {
                ZStack {
                    ForEach(0..<floatingSymbols.count, id: \.self) { index in
                        Image(systemName: floatingSymbols[index].0)
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.15))
                            .position(floatingSymbols[index].1)
                            .rotationEffect(.degrees(floatingSymbols[index].2))
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 2...4))
                                    .repeatForever(autoreverses: true),
                                value: floatingSymbols[index].2
                            )
                    }
                }
                .frame(height: 200) // Constrain floating symbols
                
                Spacer()
            }
            
            // Main content
            VStack(spacing: 30) {
                Spacer()
                
                // Medical logo/profile circle with rotation
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 180, height: 180)
                        .blur(radius: 1)
                    
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: "stethoscope.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: .white.opacity(0.5), radius: 10)
                }
                .padding(.bottom, 20)
                
                // Title with glow effect
                Text("Healing Heroes")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                
                Text("Collaborative Learning")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Main content buttons
                if sharePlayManager.sessionInfo.session != nil {
                    launchCameraButton
                        .transition(.scale.combined(with: .opacity))
                } else if groupStateObserver.isEligibleForGroupSession {
                    startSharePlayButton
                        .transition(.scale.combined(with: .opacity))
                } else {
                    inviteToSharePlayButton
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isActivitySharingSheetPresented) {
            ActivitySharingViewController(activity: MyGroupActivity())
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            animateFloatingSymbols()
        }
    }
    
    var launchCameraButton: some View {
        Button(action: {
            Task { @MainActor in
                GameStateManager.shared.gameState = .inGame
            }
        }) {
            actionButton(title: "Start Session", icon: "play.fill")
        }
    }
    
    var startSharePlayButton: some View {
        Button(action: {
            Task { @MainActor in
                sharePlayManager.startSharePlay()
                isSharePlayActive.toggle()
            }
        }) {
            actionButton(
                title: isSharePlayActive ? "Stop SharePlay" : "Start SharePlay",
                icon: "person.2.fill"
            )
        }
    }
    
    var inviteToSharePlayButton: some View {
        VStack(spacing: 20) {
            Text("Join Interactive Training")
                .font(.title2.bold())
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.3), radius: 5)
            
            Text("Invite colleagues to practice together")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button {
                isActivitySharingSheetPresented = true
            } label: {
                actionButton(title: "Start SharePlay Session", icon: "person.2.badge.gearshape")
            }
        }
        .padding(.bottom, 30)
    }
    
    private func animateFloatingSymbols() {
        for index in 0..<floatingSymbols.count {
            withAnimation(Animation.easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)) {
                    floatingSymbols[index].1.y += CGFloat.random(in: -50...50)
                    floatingSymbols[index].2 += Double.random(in: -45...45)
                }
        }
    }
    
    func actionButton(title: String, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            Text(title)
                .font(.system(size: 20, weight: .semibold))
        }
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
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 30)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        MainViewIphone()
    } else {
        Text("iOS 17.0+ required")
    }
}
