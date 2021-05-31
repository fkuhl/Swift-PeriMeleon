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

    //Note that the transitions work because changes to isEditing are withAnimation.
    var body: some View {
        if isEditing {
            MemberEditView(
                document: $document,
                member: document.member(byId: memberId),
                memberEditDelegate: MemberViewEditDelegate(document: $document),
                memberCancelDelegate: MemberViewCancelDelegate(),
                isEditing: $isEditing)
                //.transition(AnyTransition.scale.animation(.easeInOut(duration: 1)))
                .transition(.move(edge: .trailing))
        } else {
            CoreMemberView(document: $document,
                           member: document.member(byId: memberId),
                           memberEditDelegate: MemberViewEditDelegate(document: $document),
                           memberCancelDelegate: MemberViewCancelDelegate(),
                           editable: self.editable,
                           isEditing: $isEditing)
                //.transition(AnyTransition.scale.animation(.easeInOut(duration: 1)))
                .transition(.move(edge: .trailing))
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
    
    func store(member: Member) {
        NSLog("MemberEditViewDel onDis: val is \(member.fullName())")
        document.wrappedValue.update(member: member)
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
