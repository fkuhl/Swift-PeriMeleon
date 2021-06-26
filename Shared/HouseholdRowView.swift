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
    @Binding var document: PeriMeleonDocument
    var householdId: ID
    
    var body: some View {
        NavigationLink(destination: HouseholdView(document: $document,
                                                  household: document.household(byId: householdId),
                                                  spouseFactory: SpouseFactory(document: $document, household: document.household(byId: householdId)),
                                                  otherFactory: OtherFactory(document: $document, household: document.household(byId: householdId)))) {
            Text(document.nameOf(household: householdId)).font(.body)
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    let household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        newval.household = self.household.id
        newval.givenName = "Spouse"
        newval.familyName = document.wrappedValue.member(byId: self.household.head).familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.spouse = document.wrappedValue.member(byId:self.household.head).fullName()
        return newval
    }
}

fileprivate class OtherFactory: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    let household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        newval.household = self.household.id
        newval.givenName = "No. \(self.household.others.count + 1)"
        newval.familyName = document.wrappedValue.member(byId: self.household.head).familyName
        newval.status = .NONCOMMUNING
        newval.father = document.wrappedValue.member(byId: self.household.head).id
        if let mom = self.household.spouse {
            newval.mother = document.wrappedValue.member(byId: mom).id
        }
        return newval
    }
}

//struct HouseholdRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdRowView()
//    }
//}
