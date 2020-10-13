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
    var household: NormalizedHousehold
    
    var body: some View {
        NavigationLink(destination: HouseholdView(document: $document,
                                                  item: household,
                                                  spouseFactory: SpouseFactory(document: $document, household: household),
                                                  otherFactory: OtherFactory(document: $document, household: household))) {
            Text($document.wrappedValue.content.nameOf(household: household)).font(.body)
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
        newval.familyName = document.wrappedValue.content.member(byId: self.household.head).familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.spouse = document.wrappedValue.content.member(byId:self.household.head).fullName()
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
        newval.familyName = document.wrappedValue.content.member(byId: self.household.head).familyName
        newval.status = .NONCOMMUNING
        newval.father = document.wrappedValue.content.member(byId: self.household.head).id
        if let mom = self.household.spouse {
            newval.mother = document.wrappedValue.content.member(byId: mom).id
        }
        return newval
    }
}

//struct HouseholdRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdRowView()
//    }
//}
