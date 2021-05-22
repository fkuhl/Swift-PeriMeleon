//
//  PasswordView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

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
                SolidButton(text: buttonText, action: buttonAction )
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
