//
//  PeriMeleonApp.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI

@main
struct PeriMeleonApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PeriMeleonDocument.init) { file in
            ContentView(document: file.document)
                .onAppear() {
                    InjectedValues[\.periMeleonDocument] = file.document
                }
        }
    }
}
