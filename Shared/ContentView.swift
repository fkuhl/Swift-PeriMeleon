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

struct MainView: View {
    @Binding var document: PeriMeleonDocument
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            MembersView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Members")
                }
                .tag(0)
            HouseholdsView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Households")
                }
                .tag(1)
            DataTransactionsView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "pencil.circle")
                    Text("DB Transactions")
                }
                .tag(2)
            QueriesView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Queries")
                }
                .tag(3)
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


let defaultCaptionWidth: CGFloat = 150
let editAnimationDuration = 0.7

extension View {
    func debugPrint(_ value: Any) -> some View {
        #if DEBUG
        print(value)
        #endif
        return self
    }
}
