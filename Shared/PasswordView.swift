//
//  PasswordView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

struct PasswordView: View {
    var label: String
    @Binding var document: PeriMeleonDocument
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
                        switch document.content.state {
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
        switch document.content.state {
        case .newFile, .passwordEntriesDoNotMatch:
            document.content.addPasswordToNewFile(firstAttempt: firstAttempt,
                                                  secondAttempt: secondAttempt)
            firstAttempt = ""
            secondAttempt = ""
        default:
            document.content.tryPassword(firstAttempt: firstAttempt)
            firstAttempt = ""
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(label: "Enter a Password",
                     document: mockDocument,
                     buttonText: "Press me")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
