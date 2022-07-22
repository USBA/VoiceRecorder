//
//  AudioPlayer.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var currentlyPlaying: Recording?
    @Published var isPlaying = false
    
    var audioPlayer: AVAudioPlayer?
    
    func startPlayback(recording: Recording) {
        if let recordingData = recording.recordingData {
            let playbackSession = AVAudioSession.sharedInstance()
            
            
            do {
                try playbackSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.spokenAudio)
                print("Start Recording - Playback session setted")
            } catch {
                print("Play Recording - Failed to set up playback session")
            }
            
            do {
                audioPlayer = try AVAudioPlayer(data: recordingData)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                isPlaying = true
                print("Play Recording - Playing")
                withAnimation(.spring()) {
                    currentlyPlaying = recording
                }
            } catch {
                print("Play Recording - Playback failed: - \(error)")
                withAnimation {
                    currentlyPlaying = nil
                }
            }
        } else {
            print("Play Recording - Could not get the recording data")
            withAnimation {
                currentlyPlaying = nil
            }
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        print("Play Recording - Paused")
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        print("Play Recording - Resumed")
    }
    
    func stopPlayback() {
        if audioPlayer?.isPlaying ?? false {
            audioPlayer?.stop()
            isPlaying = false
            print("Play Recording - Stopped")
            withAnimation(.spring()) {
                self.currentlyPlaying = nil
            }
        } else {
            print("Play Recording - Failed to Stop playing - Coz the recording is not playing")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
            print("Play Recording - Recoring finished playing")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.spring()) {
                    self.currentlyPlaying = nil
                }
            }
        }
    }
    
}
