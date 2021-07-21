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
    @EnvironmentObject var document: PeriMeleonDocument
    @State var memberId: ID
    var editable = true
    @State private var isEditing = false
    @Binding var changeCount: Int

    //Note that the transitions work because changes to isEditing are withAnimation.
    var body: some View {
        if isEditing {
            MemberEditView(member: document.member(byId: memberId),
                           memberEditDelegate: MemberViewEditDelegate(document: document),
                           memberCancelDelegate: MemberViewCancelDelegate(),
                isEditing: $isEditing,
                changeCount: $changeCount)
                .transition(.move(edge: .trailing))
        } else {
            CoreMemberView(memberId: memberId,
                           editable: self.editable,
                           isEditing: $isEditing)
                .transition(.move(edge: .trailing))
        }
            //.debugPrint("MemberView \(member.fullName())")
    }
}
/**
 Delegate implementation used only by MemberView.
 */
fileprivate class MemberViewEditDelegate: MemberEditDelegate {
    var document: PeriMeleonDocument
    @Environment(\.undoManager) var undoManager
    
    init(document: PeriMeleonDocument) {
        self.document = document
    }

    func store(member: Member) {
        NSLog("MemberEditViewDel onDis: val is \(member.fullName())")
        document.update(member: member , undoManager: undoManager)
    }
}

fileprivate class MemberViewCancelDelegate: MemberCancelDelegate {
    func cancel() { }
}
