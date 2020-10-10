//
//  EditDisplayView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

/**
 In the MemberEditView, display a message in a row, rather than an editing control.
 */

struct EditDisplayView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    var message: String
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Text(message).font(.body)
        }
    }
}

struct EditDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        EditDisplayView(caption: "a field", message: "A Message")
    }
}
