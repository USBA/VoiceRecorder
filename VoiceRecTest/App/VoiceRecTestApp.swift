//
//  VoiceRecTestApp.swift
//  VoiceRecTest
//
//  Created by Umayanga Alahakoon on 2022-07-21.
//

import SwiftUI

@main
struct VoiceRecTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // always use dark mode
                .preferredColorScheme(.dark)
        }
    }
}
