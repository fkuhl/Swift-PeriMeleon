//
//  PeriMeleonApp.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI

@main
struct PeriMeleonApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        DocumentGroup(newDocument: PeriMeleonDocument.init) { file in
            NavigationView {
                ContentView(document: file.document,
                            fileName: file.fileURL?.lastPathComponent ?? "[none]")
            }.environmentObject(file.document)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("App is active")
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in background")
            @unknown default:
                print("Oh - interesting: I received an unexpected new value: \(scenePhase)")
            }
        }
    }
}
