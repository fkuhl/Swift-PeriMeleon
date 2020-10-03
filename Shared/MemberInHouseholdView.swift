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
    var member: Member
    @Binding var household: Household
    var relation: HouseholdRelation
    var editable = true
    
    var body: some View {
        CoreMemberView(member: self.member,
                       memberEditDelegate: MemberInHouseholdViewEditDelegate(
                        relation: self.relation),
                       memberCancelDelegate: MemberInHouseholdViewCancelDelegate(),
                       editable: self.editable,
                       closingAction: { $1.store(member: $0, in: self.$household) })
    }
}

fileprivate class MemberInHouseholdViewEditDelegate: MemberEditDelegate {
    var relation: HouseholdRelation
    
    init(relation: HouseholdRelation) {
        self.relation = relation
    }
    
    func store(member: Member, in household: Binding<Household>?) {
        guard let household = household  else {
            NSLog("MIHVED with nil household")
            return
        }
        NSLog("MIHVED store '\(member.fullName())' in household '\(household.wrappedValue.head.fullName())'")
        switch self.relation {
        case .head:
            household.wrappedValue.head = member
        case .spouse:
            household.wrappedValue.spouse = member
            household.wrappedValue.head.maritalStatus = .MARRIED
            household.wrappedValue.head.spouse = member.fullName()
            household.wrappedValue.head.dateOfMarriage = member.dateOfMarriage
        case .other:
            if let otherIndex = household.wrappedValue.others.firstIndex(where: {$0.id == member.id}) {
                household.wrappedValue.others[otherIndex] = member
            } else {
                NSLog("MIHVED no entry for other \(member.id)")
            }
        }
        NSLog("MIHVED spouse '\(household.wrappedValue.spouse?.fullName() ?? "[none]")'")
        NSLog("MIHVED storing with \(household.wrappedValue.others.count) others")
        DataFetcher.sharedInstance.update(household: household.wrappedValue)
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
