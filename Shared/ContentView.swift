//
//  ContentView.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PeriMeleonDocument

    var body: some View {
        switch (document.content.state) {
        case .normal:
            MainView(document: $document)
        case .newFile:
            PasswordView(label: "Please provide password for new document:",
                         document: $document,
                         buttonText: "Open New Document")
        case .noKey:
            PasswordView(label: "Please provide a password for the file:",
                         document: $document,
                         buttonText: "Open")
        case .cannotRead:
            Text("cannot read: corrupt document?")
        case .nowWhat(let message):
            Text(message)
        case .cannotDecrypt:
            PasswordView(label: "Unable to decrypt the file; please provide another password:",
                         document: $document,
                         buttonText: "Open")
        case .cannotDecode(let d1, let d2, let d3):
            cannotDecode(d1: d1, d2: d2, d3: d3)
        case .passwordEntriesDoNotMatch:
            PasswordView(label: "Passwords didn't match. Please enter again:",
                         document: $document.animation(),
                         buttonText: "Open")
        }
    }
    
    private func cannotDecode(d1: String, d2: String, d3: String) -> some View {
        VStack(alignment: .leading) {
            Text("Alas, the file cannot be decoded.").font(.headline)
            Text("This probably should be brought to the attention of the developer.")
                .font(.body)
            Text("Some additional information:").font(.body)
            Text("Basic error: " + d1).font(.body)
            Text("Coding path, if any: " + d2).font(.body)
            Text("Underlying error: " + d3).font(.body)
        }
        .padding()
    }
}


let defaultCaptionWidth: CGFloat = 150
let editAnimationDuration = 0.7
