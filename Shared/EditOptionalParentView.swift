//
//  EditOptionalParentView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/28/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct EditOptionalParentView: View {
    @Injected(\.periMeleonDocument) var document: PeriMeleonDocument
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    var sex: Sex
    @Binding var parentId: ID?
    let title: String
    
    var body: some View {
        let proxyBinding = Binding<ID> (
            get: { self.parentId ?? ""  },
            set: { self.parentId = $0 })
        
        return NavigationLink(destination: ChooseParentListView(parentId: proxyBinding,
                                                                sex: sex,
                                                                title: title)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(document.nameOf(member: parentId ?? "[none]")).font(.body)
            }
        }
    }
}

struct ChooseParentListView: View {
    @Injected(\.periMeleonDocument) var document: PeriMeleonDocument
    @Binding var parentId: ID
    var sex: Sex
    let title: String
    
    var body: some View {
        List {
            ForEach(document.parentList(mustBeActive: true, sex: sex)) {
                ChooseParentRowView(member: $0, chosenId: self.$parentId)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        Text(title)
                    })})
    }
}

struct ChooseParentRowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var member: Member
    @Binding var chosenId: ID
    
    var body: some View {
        HStack {
            Button(action: {
                self.chosenId = self.member.id
                self.presentationMode.wrappedValue.dismiss()
            } ) {
                Text(member.fullName()).font(.body)
            }
        }
    }

}
