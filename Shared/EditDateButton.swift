//
//  EditDateButton.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/28/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct EditDateButton: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var date: Date?
    
    var body: some View {
        HStack {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            if date != nil {
                Button(action: { self.date = nil }) {
                    Text("Remove Date").font(.body)
                }
            }
        }
    }
}

//struct EditDateButton_Previews: PreviewProvider {
//    static var previews: some View {
//        EditDateButton()
//    }
//}
