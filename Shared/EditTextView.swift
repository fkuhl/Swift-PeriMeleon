//
//  EditTextView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct EditTextView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            TextField(caption, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disableAutocorrection(true)
            .frame(alignment: .leading)
            .font(.body)
        }
    }
}

struct EditTextView_Previews: PreviewProvider {
    static var previews: some View {
        EditTextView(caption: "a field", text: .constant("stuff"))
    }
}
