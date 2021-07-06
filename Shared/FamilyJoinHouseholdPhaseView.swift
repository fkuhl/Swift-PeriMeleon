//
//  PhaseTwoView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/5/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct FamilyJoinHouseholdPhaseView: View {
    @EnvironmentObject var model: Model
    @Binding var accumulator: FamilyJoinAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    NSLog("FJTPV Finish")
                    accumulator.phase = .reset
                    linkSelection = nil //ensure WorkflowsView can go again
                    
                }) {
                    Text("Finish").font(.body)
                }
            }.padding()
            HouseholdView(householdId: accumulator.addedHousehold.id,
                          replaceButtons: false,
                          spouseFactory: SpouseFactory(
                            model: model,
                            householdId: accumulator.addedHousehold.id),
                          otherFactory: OtherFactory(
                            model: model,
                            householdId: accumulator.addedHousehold.id))
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    var model: Model
    var householdId: ID
    
    init(model: Model, householdId: ID) {
        self.model = model
        self.householdId = householdId
    }
    
    func make() -> Member {
        var newval = Member()
        NSLog("made spouse \(newval.id)")
        var household = model.household(byId: householdId)
        let head = model.member(byId: household.head)
        newval.household = household.id
        newval.givenName = "Spouse"
        newval.familyName = head.familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.dateOfMarriage = head.dateOfMarriage
        newval.spouse = model.nameOf(member: household.head)
        if let trans = model.member(byId: household.head).transactions.first {
            newval.transactions.append(trans)
        }
        model.add(member: newval)
        household.spouse = newval.id
        model.update(household: household)
        return newval
    }
}

fileprivate class OtherFactory: HouseholdMemberFactoryDelegate {
    var model: Model
    var householdId: ID
    
    init(model: Model, householdId: ID) {
        self.model = model
        self.householdId = householdId
    }
    
    func make() -> Member {
        let household = model.household(byId: householdId)
        var newval = Member()
        newval.household = household.id
        newval.givenName = "No. \(household.others.count + 1)"
        let head = model.member(byId: household.head)
        newval.familyName = head.familyName
        newval.status = .NONCOMMUNING
        if let trans = head.transactions.first {
            newval.transactions.append(trans)
        }
        newval.father = head.id
        if let mom = household.spouse {
            newval.mother = model.member(byId: mom).id
        }
        model.add(member: newval)
        return newval
    }
}
