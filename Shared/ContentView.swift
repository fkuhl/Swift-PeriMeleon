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
        switch (document.state) {
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
        case .cannotDecrypt:
            PasswordView(label: "Unable to decrypt the file; please provide another password:",
                         document: $document,
                         buttonText: "Open")
        case .cannotDecode(let d1, let d2, let d3):
            cannotDecode(basicError: d1, codingPath: d2, underlyingError: d3)
        case .saveError(let d1, let d2, let d3):
            saveError(basicError: d1, codingPath: d2, underlyingError: d3)
        case .passwordEntriesDoNotMatch:
            PasswordView(label: "Passwords didn't match. Please enter again:",
                         document: $document.animation(),
                         buttonText: "Open")
        }
    }
    
    private func cannotDecode(basicError: String,
                              codingPath: String,
                              underlyingError: String) -> some View {
        VStack(alignment: .leading) {
            Text("Alas, the file cannot be decoded.").font(.headline)
            Text("This probably should be brought to the attention of the developer.")
                .font(.body)
            Text("Some additional information:").font(.body)
            Text("Basic error: " + basicError).font(.body)
            Text("Coding path, if any: " + codingPath).font(.body)
            Text("Underlying error: " + underlyingError).font(.body)
        }
        .padding()
    }
    
    private func saveError(basicError: String,
                           codingPath: String,
                           underlyingError: String) -> some View {
        VStack(alignment: .leading) {
            Text("Alas, the file could not be saved.").font(.headline)
            Text("This probably should be brought to the attention of the developer.")
                .font(.body)
            Text("Some additional information:").font(.body)
            Text("Basic error: " + basicError).font(.body)
            Text("Coding path, if any: " + codingPath).font(.body)
            Text("Underlying error: " + underlyingError).font(.body)
        }
        .padding()
    }
}


let defaultCaptionWidth: CGFloat = 150
let editAnimationDuration = 0.7
