//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/1/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MemberView: View {
    @Binding var document: PeriMeleonDocument
    var memberId: Id
    var editable = true
    @State private var isEditing = false

    var body: some View {
        if isEditing {
            MemberEditView(
                document: $document,
                member: document.content.member(byId: memberId),
                memberEditDelegate: MemberViewEditDelegate(document: $document),
                memberCancelDelegate: MemberViewCancelDelegate(),
                closingAction: { $1.store(member: $0, in: nil) },
                isEditing: $isEditing)
        } else {
            CoreMemberView(document: $document,
                           member: document.content.member(byId: memberId),
                           memberEditDelegate: MemberViewEditDelegate(document: $document),
                           memberCancelDelegate: MemberViewCancelDelegate(),
                           editable: self.editable,
                           closingAction: { $1.store(member: $0, in: nil) },
                           isEditing: $isEditing)
        }
            //.debugPrint("MemberView \(member.fullName())")
    }
}
/**
 Delegate implementation used only by MemberView.
 */
fileprivate class MemberViewEditDelegate: MemberEditDelegate {
    var document: Binding<PeriMeleonDocument>
    
    init(document: Binding<PeriMeleonDocument>) {
        self.document = document
    }
    
    func store(member: Member, in household: Binding<NormalizedHousehold>? = nil) {
        NSLog("MemberEditViewDel onDis: val is \(member.fullName())")
        document.wrappedValue.content.update(member: member)
    }
}

fileprivate class MemberViewCancelDelegate: MemberCancelDelegate {
    func cancel() { }
}

//struct MemberView_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberView(member: member1)
//    }
//}
