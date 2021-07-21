//
//  PasswordView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

struct PasswordView: View {
    @Injected(\.periMeleonDocument) var document: PeriMeleonDocument
    var label: String
    var buttonText: String
    @State var firstAttempt = ""
    @State var secondAttempt = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(label).font(.headline)
                HStack {
                    Spacer().frame(width: geometry.size.width / 4)
                    VStack {
                        SecureField("type password", text: $firstAttempt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        switch document.state {
                        case .newFile, .passwordEntriesDoNotMatch:
                            SecureField("re-type password", text: $secondAttempt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        default:
                            EmptyView()
                        }
                    }
                    Spacer().frame(width: geometry.size.width / 4)
                }.padding()
                SolidButton(text: buttonText, action: buttonAction )
            }
            .padding()
        }
    }
    
    private func buttonAction() {
        switch document.state {
        case .newFile, .passwordEntriesDoNotMatch:
            document.addPasswordToNewFile(firstAttempt: firstAttempt,
                                          secondAttempt: secondAttempt)
            firstAttempt = ""
            secondAttempt = ""
        default:
            document.tryPassword(firstAttempt: firstAttempt)
            firstAttempt = ""
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(label: "Enter a Password",
                     buttonText: "Press me")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
