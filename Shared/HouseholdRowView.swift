//
//  HouseholdRowView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/14/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct HouseholdRowView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var householdId: ID
    
    var body: some View {
        NavigationLink(destination: HouseholdView(householdId: householdId,
                                                  spouseFactory: SpouseFactory(
                                                    document: document,
                                                    householdId: householdId),
                                                  otherFactory: OtherFactory(
                                                    document: document,
                                                    householdId: householdId))
                        .environmentObject(document)) {
            Text(document.nameOf(household: householdId)).font(.body)
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    var document: PeriMeleonDocument
    let householdId: ID
    
    init(document: PeriMeleonDocument, householdId: ID) {
        self.document = document
        self.householdId = householdId
    }
    
    func make() -> Member {
        let household = document.household(byId: householdId)
        let head = document.member(byId: household.head)
        var newval = Member()
        newval.household = household.id
        newval.givenName = "Spouse"
        newval.familyName = head.familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.dateOfMarriage = head.dateOfMarriage
        newval.spouse = head.fullName()
        return newval
    }
}

fileprivate class OtherFactory: HouseholdMemberFactoryDelegate {
    var document: PeriMeleonDocument
    let householdId: ID
    
    init(document: PeriMeleonDocument, householdId: ID) {
        self.document = document
        self.householdId = householdId
    }
    
    func make() -> Member {
        let household = document.household(byId: householdId)
        var newval = Member()
        newval.household = household.id
        newval.givenName = "No. \(household.others.count + 1)"
        newval.familyName = document.member(byId: household.head).familyName
        newval.status = .NONCOMMUNING
        newval.father = document.member(byId: household.head).id
        if let mom = household.spouse {
            newval.mother = document.member(byId: mom).id
        }
        return newval
    }
}
