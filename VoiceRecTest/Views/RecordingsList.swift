//
//  RecordingsList.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import SwiftUI
import CoreData

struct RecordingsList: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var audioPlayer: AudioPlayer
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: true)],
        animation: .default)
    private var recordings: FetchedResults<Recording>
    
    var body: some View {
        List {
            ForEach(recordings, id: \.id) { recording in
                RecordingRow(audioPlayer: audioPlayer, recording: recording)
            }
                .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation {
            offsets.map { recordings[$0] }.forEach(moc.delete)

            do {
                try moc.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecordingRow: View {
    @ObservedObject var audioPlayer: AudioPlayer
    var recording: Recording
    
    var body: some View {
        HStack {
            Text(recording.name ?? "Recording")
                .fontWeight(audioPlayer.currentlyPlaying?.id == recording.id ? .bold : .regular)
            Spacer()
            Button {
                audioPlayer.startPlayback(recording: recording)
            } label: {
                Image(systemName: "play.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, .tertiary)
            }

        }
    }
}

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList(audioPlayer: AudioPlayer())
    }
}
