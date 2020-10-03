//
//  MemberTextAttributeView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/29/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct TextAttributeView: View {
    var caption: String
    var text: String?
    
    var body: some View {
        HStack {
            Text(caption)
                .frame(width: defaultCaptionWidth, alignment: .trailing) //a magic number for you
                .font(.caption)
            Text(text ?? "[none]")
                .frame(alignment: .leading)
                .font(.body)
        }
    }
}

struct TextAttributeView_Previews: PreviewProvider {
    static var previews: some View {
        TextAttributeView(caption: "some caption", text: "some text")
    }
}
