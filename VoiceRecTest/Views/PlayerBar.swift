//
//  PlayerBar.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import SwiftUI

struct PlayerBar: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @State var sliderValue: Double = 0.0
    @State private var isDragging = false
    
    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        if let player = audioPlayer.audioPlayer, let currentlyPlaying = audioPlayer.currentlyPlaying {
            VStack {
                
                // Slider
                Slider(value: $sliderValue, in: 0...player.duration) { dragging in
                    print("Editing the slider: \(dragging)")
                    isDragging = dragging
                    if !dragging {
                        player.currentTime = sliderValue
                    }
                }
                    .tint(.primary)
                
                // Time passed & Time remaining
                HStack {
                    Text(DateComponentsFormatter.positional.string(from: player.currentTime) ?? "0:00")
                    Spacer()
                    Text(DateComponentsFormatter.positional.string(from: (player.currentTime - player.duration) ) ?? "0:00")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack(spacing: 15) {
                    if self.audioPlayer.isPlaying {
                        // Pause Button
                        Button(action: {
                            self.audioPlayer.pausePlayback()
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.title2)
                                .imageScale(.large)
                        }
                    } else {
                        // Resume Button
                        Button(action: {
                            self.audioPlayer.resumePlayback()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.title2)
                                .imageScale(.large)
                        }
                    }
                    
                    // Recording name
                    Text(currentlyPlaying.name ?? "Recording")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Stop button
                    Button(action: {
                        self.audioPlayer.stopPlayback()
                        sliderValue = 0
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                }
                .padding(.top, 10)
            }
            .padding()
            .foregroundColor(.primary)
            .onReceive(timer) { _ in
                guard let player = self.audioPlayer.audioPlayer, !isDragging else { return }
                sliderValue = player.currentTime
            }
            .transition(.scale(scale: 0, anchor: .bottom))
            
            Divider()
        }
    }
}

struct PlayerBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerBar(audioPlayer: AudioPlayer())
    }
}
