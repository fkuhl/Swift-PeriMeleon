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
    
    var body: some View {
        CoreMemberView(document: $document,
                       member: self.member,
                       memberEditDelegate: MemberInHouseholdViewEditDelegate(
                        document: $document, household: household),
                       memberCancelDelegate: MemberInHouseholdViewCancelDelegate(),
                       editable: self.editable,
                       closingAction: { $1.store(member: $0, in: self.$household) })
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
//        if member.id == household.wrappedValue.head {
//            household.wrappedValue.head = member.id
//        } else if household.wrappedValue.spouse == member.id {
//            var adjustedHead = document.wrappedValue.content.member(byId: household.wrappedValue.head)
//            adjustedHead.maritalStatus = .MARRIED
//            adjustedHead.spouse = member.fullName()
//            adjustedHead.dateOfMarriage = member.dateOfMarriage
//            document.wrappedValue.content.update(member: adjustedHead)
//        } else {
//            household.wrappedValue.others.forEach { other in
//                if other == member.id {
//
//                }
//            }
//        }
        
        
//        switch self.relation {
//        case .head:
//            household.wrappedValue.head = member
//        case .spouse:
//            household.wrappedValue.spouse = member
//            household.wrappedValue.head.maritalStatus = .MARRIED
//            household.wrappedValue.head.spouse = member.fullName()
//            household.wrappedValue.head.dateOfMarriage = member.dateOfMarriage
//        case .other:
//            if let otherIndex = household.wrappedValue.others.firstIndex(where: {$0.id == member.id}) {
//                household.wrappedValue.others[otherIndex] = member
//            } else {
//                NSLog("MIHVED no entry for other \(member.id)")
//            }
//        }
//        NSLog("MIHVED spouse '\(household.wrappedValue.spouse?.fullName() ?? "[none]")'")
//        NSLog("MIHVED storing with \(household.wrappedValue.others.count) others")
//        document.wrappedValue.content.update(household: household.wrappedValue)
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
