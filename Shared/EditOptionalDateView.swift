//
//  EditOptionalDateView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct EditOptionalDateView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var date: Date?
    

    var body: some View {
        let proxyBinding = Binding<Date> (
            get: { self.date ?? Date() },
            set: { self.date = $0 })
        
        return HStack {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            if date == nil {
                HStack {
                    Text("[no date]").font(.body)
                    Spacer()
                    Button(action: { self.date = Date() }) {
                        Text("Add Date").font(.body)
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    DatePicker("",
                               selection: proxyBinding,
                               in: ...Date(),
                               displayedComponents: .date).font(.body)
                }
                Spacer()
                Button(action: { self.date = nil }) {
                    Text("Remove Date").font(.body)
                }
            }
        }
    }
}

//struct EditOptionalDateView_Previews: PreviewProvider {
//    static var previews: some View {
//        private var aDate = Date()
//        EditOptionalDateView(caption: "date", date: aDate)
//    }
//}
