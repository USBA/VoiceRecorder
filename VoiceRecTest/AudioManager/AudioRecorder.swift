//
//  AudioRecorder.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import CoreData

class AudioRecorder: NSObject,ObservableObject {
    
    let moc = PersistenceController.shared.container.viewContext

    var audioRecorder: AVAudioRecorder?
    
    @Published private var recordingName = "Recording1"
    @Published private var recordingDate = Date()
    @Published private var recordingURL: URL?
    
    @Published var isRecording = false
    
    // MARK: - Start Recording
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            print("Start Recording - Recording session setted")
        } catch {
            print("Start Recording - Failed to set up recording session")
        }
        
        let currentDateTime = Date.now
        
        recordingDate = currentDateTime
        recordingName = "\(currentDateTime.toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss"))"
        
        // save the recording to the temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let recordingFileURL = tempDirectory.appendingPathComponent(recordingName).appendingPathExtension("m4a")
        recordingURL = recordingFileURL
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingFileURL, settings: settings)
            audioRecorder?.record()
            
            withAnimation {
                isRecording = true
            }
            print("Start Recording - Recording Started")
        } catch {
            print("Start Recording - Could not start recording")
        }
    }
    
    // MARK: - Stop Recording
    
    func stopRecording() {
        audioRecorder?.stop()
        withAnimation {
            isRecording = false
        }
        
        if let recordingURL {
            do {
                let recordingDate = try Data(contentsOf: recordingURL)
                print("Stop Recording - Saving to CoreData")
                // save the recording to CoreData
                saveRecordingOnCoreData(recordingData: recordingDate)
            } catch {
                print("Stop Recording - Could not save to CoreData - Cannot get the recording data from URL: \(error)")
            }
            
        } else {
            print("Stop Recording -  Could not save to CoreData - Cannot find the recording URL")
        }
        
    }
    
    // MARK: - CoreData --------------------------------------
    
    func saveRecordingOnCoreData(recordingData: Data) {
        let newRecording = Recording(context: moc)
        newRecording.id = UUID()
        newRecording.name = recordingName
        newRecording.createdAt = recordingDate
        newRecording.recordingData = recordingData
        
        do {
            try moc.save()
            print("Stop Recording - Successfully saved to CoreData")
            // delete the recording stored in the temporary directory
            deleteRecordingFile()
        } catch {
            let nsError = error as NSError
            fatalError("Stop Recording - Failed to save to CoreData - Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteRecordingFile() {
        if let recordingURL {
            do {
               try FileManager.default.removeItem(at: recordingURL)
                print("Stop Recording - Successfully deleted the recording file")
            } catch {
                print("Stop Recording - Could not delete the recording file - Cannot find the recording URL")
            }
        }
    }
    
}
