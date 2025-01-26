//
//  AudioManager.swift
//  BadApplesRealityHack
//
//  Created by Feolu Kolawole on 1/26/25.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var soundEffects: [String: SystemSoundID] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // For longer sounds (background music, etc.)
    func playSound(named filename: String, fileExtension: String = "mp3", volume: Float = 1.0, loops: Int = 0) {
        guard let path = Bundle.main.path(forResource: filename, ofType: fileExtension) else {
            print("Failed to find sound file: \(filename).\(fileExtension)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        if let existingPlayer = audioPlayers[filename] {
            existingPlayer.volume = volume
            existingPlayer.numberOfLoops = loops
            existingPlayer.currentTime = 0
            existingPlayer.play()
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.numberOfLoops = loops
            player.prepareToPlay()
            audioPlayers[filename] = player
            player.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    // For short sound effects (better performance)
    func playSoundEffect(named filename: String, fileExtension: String = "wav") {
        if let soundID = soundEffects[filename] {
            AudioServicesPlaySystemSound(soundID)
            return
        }
        
        guard let path = Bundle.main.path(forResource: filename, ofType: fileExtension) else {
            print("Failed to find sound effect file: \(filename).\(fileExtension)")
            return
        }
        
        var soundID: SystemSoundID = 0
        let url = URL(fileURLWithPath: path) as CFURL
        AudioServicesCreateSystemSoundID(url, &soundID)
        soundEffects[filename] = soundID
        AudioServicesPlaySystemSound(soundID)
    }
    
    func stopSound(named filename: String) {
        audioPlayers[filename]?.stop()
    }
    
    func pauseSound(named filename: String) {
        audioPlayers[filename]?.pause()
    }
    
    func resumeSound(named filename: String) {
        audioPlayers[filename]?.play()
    }
    
    func setVolume(_ volume: Float, forSound filename: String) {
        audioPlayers[filename]?.volume = volume
    }
    
    // Cleanup
    func cleanup() {
        audioPlayers.forEach { $0.value.stop() }
        audioPlayers.removeAll()
        
        soundEffects.forEach { AudioServicesDisposeSystemSoundID($0.value) }
        soundEffects.removeAll()
    }
}

// MARK: - Sound Names Enum
enum SoundEffect: String {
    case buttonTap = "button_tap"
    case success = "success"
    case failure = "failure"
    case heartCollect = "heart_collect"
    // Add more sound effects as needed
}

enum BackgroundMusic: String {
    case lobby = "LobbyMusic"
    // Add more background music as needed
}
