//
//  MemberInHouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/12/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

/**
 Like MemberView,  but in context of editing or adding Household.
 */

import SwiftUI
import PMDataTypes

struct MemberInHouseholdView: View {
    @Binding var document: PeriMeleonDocument
    var member: Member
    @Binding var household: NormalizedHousehold
    var editable = true
    @State private var isEditing = false
    
    var body: some View {
        CoreMemberView(document: $document,
                       member: self.member,
                       memberEditDelegate: MemberInHouseholdViewEditDelegate(
                        document: $document, household: household),
                       memberCancelDelegate: MemberInHouseholdViewCancelDelegate(),
                       editable: self.editable,
                       closingAction: { $1.store(member: $0, in: self.$household) },
                       isEditing: $isEditing)
    }
}

fileprivate class MemberInHouseholdViewEditDelegate: MemberEditDelegate {
    var document: Binding<PeriMeleonDocument>
    var household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func store(member: Member, in household: Binding<NormalizedHousehold>?) {
        guard let household = household  else {
            NSLog("MIHVED with nil household")
            return
        }
        NSLog("MIHVED store '\(member.fullName())' in household '\(document.wrappedValue.content.nameOf(household: household.wrappedValue))'")
        document.wrappedValue.content.update(member: member)
    }
}

fileprivate class MemberInHouseholdViewCancelDelegate: MemberCancelDelegate {
    func cancel() { }
}

//struct MemberInHouseholdView_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberInHouseholdView()
//    }
//}
