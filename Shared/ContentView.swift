//
//  ContentView.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PeriMeleonDocument
    @State var firstAttempt = ""
    @State var secondAttempt = ""

    var body: some View {
        switch (document.encryptor.state) {
        case .normal:
            VStack {
                HouseholdsView(households: $document.encryptor.households)
            }
        case .noKey:
            Text("no key!")
        case .cannotRead:
            Text("cant read")
        case .cannotDecrypt:
            VStack {
            Text("Unable to decrypt file; please provide another password.")
                TextField("", text: $firstAttempt)
                TextField("", text: $secondAttempt)
                Button(action: {
                    document.encryptor.tryPassword(firstAttempt: firstAttempt,
                                                   secondAttempt: secondAttempt)
                }) {
                    Text("Do It")
                }
            }.padding()
        case .cannotDecode(let description):
            VStack{
                Text("cannot read!")
                Text(description)
            }
        case .passwordEntriesDoNotMatch:
            Text("dont match")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PeriMeleonDocument()))
    }
}
