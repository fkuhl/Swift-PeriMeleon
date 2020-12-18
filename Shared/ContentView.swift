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

// TODO Sidebar?

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
    var forNewFile: Bool
    @Binding var document: PeriMeleonDocument
    var buttonText: String
    @State var firstAttempt = ""
    @State var secondAttempt = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(label).font(.headline)
                HStack {
                    Spacer().frame(width: geometry.size.width / 5)
                    VStack {
                        SecureField("type password", text: $firstAttempt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        SecureField("re-type password", text: $secondAttempt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer().frame(width: geometry.size.width / 5)
                }.padding()
                SolidButton(text: buttonText, action: { buttonAction() })
            }
        }
    }
    
    private func buttonAction() {
        if forNewFile {
            document.content.addPasswordToNewFile(firstAttempt: firstAttempt,
                                                  secondAttempt: secondAttempt)
        } else {
            document.content.tryPassword(firstAttempt: firstAttempt,
                                         secondAttempt: secondAttempt)
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(label: "Enter a Password",
                     forNewFile: true,
                     document: mockDocument,
                     buttonText: "Press me")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}


let defaultCaptionWidth: CGFloat = 150
let editAnimationDuration = 0.7
