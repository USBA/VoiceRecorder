//
//  ContentView.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var audioPlayer = AudioPlayer()
    
    @ObservedObject var audioRecorder = AudioRecorder()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    var body: some View {
        NavigationView {
            RecordingsList(audioPlayer: audioPlayer)
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                }
                .navigationTitle("Voice Recorder")
        }
    }
    
    var bottomBar: some View {
        VStack {
            PlayerBar(audioPlayer: audioPlayer)
            RecorderBar(audioPlayer: audioPlayer)
        }
        .background(.thinMaterial)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
