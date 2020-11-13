//
//  SolidButton.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/29/20.
//

import SwiftUI

//https://www.bigmountainstudio.com/members/posts/11623-5-swiftui-button-designs-every-swiftui-developer-should-know

struct SolidButton: View {
    var text = "Some Text"
    var action: () -> Void
    
    var body: some View {
        Button(action:action) {
            Text(text).font(.body).bold()
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .padding(7)
        }
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.accentColor))
    }
}

struct SolidButton_Previews: PreviewProvider {
    static var previews: some View {
        SolidButton(text: "Preview Text", action: { })
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
