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
            VStack {
                HouseholdsView(households: $document.content.households)
            }
        case .noKey:
            PasswordView(label: "No key!", document: $document)
        case .cannotRead:
            Text("cant read")
        case .cannotDecrypt:
            PasswordView(label: "Unable to decrypt file; please provide another password.", document: $document)
        case .cannotDecode(let description):
            VStack{
                Text("cannot read!")
                Text(description)
            }
        case .passwordEntriesDoNotMatch:
            PasswordView(label: "Passwords didn't match.", document: $document)
        }
    }
}

struct PasswordView: View {
    var label: String
    @Binding var document: PeriMeleonDocument
    @State var firstAttempt = ""
    @State var secondAttempt = ""

    var body: some View {
        VStack {
            Text(label)
            SecureField("type password", text: $firstAttempt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("re-type password", text: $secondAttempt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                document.content.tryPassword(firstAttempt: firstAttempt,
                                               secondAttempt: secondAttempt)
            }) {
                Text("Decrypt")
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PeriMeleonDocument()))
    }
}
