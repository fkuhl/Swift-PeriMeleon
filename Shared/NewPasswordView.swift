//
//  NewPasswordView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 3/28/22.
//

import SwiftUI

struct NewPasswordView: View {
    @EnvironmentObject var document: PeriMeleonDocument
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
                        SecureField("type password",
                                    text: $firstAttempt,
                                    onCommit: buttonAction)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        SecureField("re-type password",
                                    text: $secondAttempt,
                                    onCommit: buttonAction)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer().frame(width: geometry.size.width / 4)
                }.padding()
                HStack {
                    SolidButton(text: "Cancel", action: cancelAction)
                    SolidButton(text: buttonText, action: buttonAction )
                }
            }
            .padding()
        }
    }
    
    private func buttonAction() {
        document.changePassword(firstAttempt: firstAttempt,
                                secondAttempt: secondAttempt)
        firstAttempt = ""
        secondAttempt = ""
    }
    
    private func cancelAction() {
        document.state = .normal
    }
}

struct NewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NewPasswordView(label: "Enter a Password",
                     buttonText: "Press me")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environmentObject(mockDocument)
    }
}
