//
//  EditBoolView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct EditBoolView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var choice: Bool
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Toggle(isOn: $choice) {
                Text("").font(.body)
            }
        }
    }
}

//struct EditBoolView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditBoolView(caption: "a field", choice: true)
//    }
//}
