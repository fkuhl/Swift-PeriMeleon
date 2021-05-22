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
                         forNewFile: true,
                         document: $document,
                         buttonText: "Create Document")
        case .noKey:
            PasswordView(label: "Please provide a password:",
                         forNewFile: false,
                         document: $document,
                         buttonText: "Open")
        case .cannotRead:
            Text("cannot read: corrupt document?")
        case .nowWhat(let message):
            Text(message)
        case .cannotDecrypt:
            PasswordView(label: "Unable to decrypt document; please provide another password:",
                         forNewFile: false,
                         document: $document,
                         buttonText: "Open")
        case .cannotDecode(let description):
            VStack{
                Text("cannot decode JSON:")
                Text(description)
            }
        case .passwordEntriesDoNotMatch(let forNewFile):
            PasswordView(label: "Passwords didn't match. Please enter again:",
                         forNewFile: forNewFile,
                         document: $document.animation(),
                         buttonText: "Open")
        }
    }
}


let defaultCaptionWidth: CGFloat = 150
let editAnimationDuration = 0.7
