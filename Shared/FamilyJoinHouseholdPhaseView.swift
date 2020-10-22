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
    @Binding var linkSelection: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    NSLog("FJTPV cancel")
                    accumulator.phase = .reset
                    linkSelection = nil //ensure DataTransactionsView can go again
                    presentationMode.wrappedValue.dismiss() //dismiss FamilyJoinView?
                    
                }) {
                    Text("Finish").font(.body)
                }
            }.padding()
            HouseholdView(document: $document,
                          household: accumulator.addedHousehold,
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
        newval.household = self.household.id
        newval.givenName = "Spouse"
        newval.familyName = document.wrappedValue.content.member(byId: household.head).familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.spouse = document.wrappedValue.content.nameOf(member: household.head)
        if let trans = document.wrappedValue.content.member(byId: household.head).transactions.first {
            newval.transactions.append(trans)
        }
        household.spouse = newval.id
        document.wrappedValue.content.update(household: household)
        document.wrappedValue.content.add(member: newval)
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
        newval.familyName = document.wrappedValue.content.member(byId: household.head).familyName
        newval.status = .NONCOMMUNING
        if let trans = document.wrappedValue.content.member(byId: household.head).transactions.first {
            newval.transactions.append(trans)
        }
        newval.father = document.wrappedValue.content.member(byId: household.head).id
        if let mom = household.spouse {
            newval.mother = document.wrappedValue.content.member(byId: mom).id
        }
        document.wrappedValue.content.add(member: newval)
        //updating the household happens in OtherAddView?
        return newval
    }
}

//fileprivate func newHousehold() -> Household? {
//    return DataFetcher.sharedInstance.householdIndex[DataFetcher.sharedInstance.addedHouseholdId]
//}

//struct PhaseTwoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhaseTwoView()
//    }
//}
