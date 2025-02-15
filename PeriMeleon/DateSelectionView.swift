//
//  DateSelectionView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 9/1/21.
//

import SwiftUI

struct DateSelectionView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var date: Date

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            DatePicker("",
                       selection: $date,
                       in: ...Date(),
                       displayedComponents: .date).font(.body)
        }
    }
}

struct DateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DateSelectionView(caption: "This is a caption", date: .constant(Date()))
    }
}
