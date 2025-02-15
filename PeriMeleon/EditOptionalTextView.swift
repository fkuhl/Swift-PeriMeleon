//
//  EditOptionalTextView.swift
//  PMClient
//  Created by Frederick Kuhl on 3/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct EditOptionalTextView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var text: String?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        let proxyBinding = Binding<String> (
            get: { self.text ?? ""  },
            set: { self.text = $0 })
        
        return HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            TextField(caption, text: proxyBinding)
                .keyboardType(keyboardType)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disableAutocorrection(true)
            .frame(alignment: .leading)
            .font(.body)
        }
    }
}

struct EditOptionalTextView_Previews: PreviewProvider {
    static var previews: some View {
        EditTextView(caption: "a field", text: .constant("stuff"))
    }
}
