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
    @Binding var document: PeriMeleonDocument
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
            HouseholdView(document: $document,
                          householdId: accumulator.addedHousehold.id,
                          replaceButtons: false,
                          spouseFactory: SpouseFactory(document: $document,
                                                       household: accumulator.addedHousehold),
                          otherFactory: OtherFactory(document: $document,
                                                     household: accumulator.addedHousehold))
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    var household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        NSLog("made spouse \(newval.id)")
        let head = document.wrappedValue.member(byId: household.head)
        newval.household = self.household.id
        newval.givenName = "Spouse"
        newval.familyName = head.familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.dateOfMarriage = head.dateOfMarriage
        newval.spouse = document.wrappedValue.nameOf(member: household.head)
        if let trans = document.wrappedValue.member(byId: household.head).transactions.first {
            newval.transactions.append(trans)
        }
        household.spouse = newval.id
        document.wrappedValue.update(household: household)
        document.wrappedValue.add(member: newval)
        return newval
    }
}

fileprivate class OtherFactory: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    var household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        newval.household = household.id
        newval.givenName = "No. \(household.others.count + 1)"
        let head = document.wrappedValue.member(byId: household.head)
        newval.familyName = head.familyName
        newval.status = .NONCOMMUNING
        if let trans = head.transactions.first {
            newval.transactions.append(trans)
        }
        newval.father = head.id
        if let mom = household.spouse {
            newval.mother = document.wrappedValue.member(byId: mom).id
        }
        document.wrappedValue.add(member: newval)
        return newval
    }
}
