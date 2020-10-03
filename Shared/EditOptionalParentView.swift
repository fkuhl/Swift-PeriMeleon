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
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    var sex: Sex
    @Binding var parentId: Id?
    
    var body: some View {
        let proxyBinding = Binding<Id> (
            get: { self.parentId ?? ""  },
            set: { self.parentId = $0 })
        
        return NavigationLink(destination: ChooseParentListView(parentId: proxyBinding, sex: sex)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(nameOfMember(parentId)).font(.body)
            }
        }
    }
}

struct ChooseParentListView: View {
    @ObservedObject var dataFetcher = DataFetcher.sharedInstance
    @Binding var parentId: Id
    var sex: Sex
    
    var body: some View {
        List {
            ForEach(dataFetcher.parentList(mustBeActive: true, sex: sex), id: \.id) {
                ChooseParentRowView(member: $0, chosenId: self.$parentId)
            }
        }
    }
}

struct ChooseParentRowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var member: Member
    @Binding var chosenId: Id
    
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

//struct EditOptionalParentView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditOptionalParentView()
//    }
//}
