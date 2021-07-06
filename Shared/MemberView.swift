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
    @EnvironmentObject var model: Model
    @State var memberId: ID
    var editable = true
    @State private var isEditing = false
    @Binding var changeCount: Int

    //Note that the transitions work because changes to isEditing are withAnimation.
    var body: some View {
        if isEditing {
            MemberEditView(member: model.member(byId: memberId),
                           memberEditDelegate: MemberViewEditDelegate(model: model),
                memberCancelDelegate: MemberViewCancelDelegate(),
                isEditing: $isEditing,
                changeCount: $changeCount)
                .transition(.move(edge: .trailing))
        } else {
            CoreMemberView(member: model.member(byId: memberId),
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
    var model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    func store(member: Member) {
        NSLog("MemberEditViewDel onDis: val is \(member.fullName())")
        model.update(member: member)
    }
}

fileprivate class MemberViewCancelDelegate: MemberCancelDelegate {
    func cancel() { }
}
