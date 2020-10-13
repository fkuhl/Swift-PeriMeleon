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
    var member: Member
    var editable = true
    
    var body: some View {
        CoreMemberView(document: $document,
                       member: member,
                       memberEditDelegate: MemberViewEditDelegate(document: $document),
                       memberCancelDelegate: MemberViewCancelDelegate(),
                       editable: self.editable,
                       closingAction: { $1.store(member: $0, in: nil) })
            .debugPrint("MemberView \(member.fullName())")
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
