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
    var household: Household
    
    var body: some View {
        NavigationLink(destination: HouseholdView(document: $document,
                                                  item: household,
                                                  spouseFactory: SpouseFactory(household: household),
                                                  otherFactory: OtherFactory(household: household))) {
                                                    Text(household.head.fullName()).font(.body)
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    let household: Household
    
    init(household: Household) {
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        newval.household = self.household.id
        newval.givenName = "Spouse"
        newval.familyName = self.household.head.familyName
        newval.sex = .FEMALE
        newval.maritalStatus = .MARRIED
        newval.spouse = self.household.head.fullName()
        return newval
    }
}

fileprivate class OtherFactory: HouseholdMemberFactoryDelegate {
    let household: Household
    
    init(household: Household) {
        self.household = household
    }
    
    func make() -> Member {
        var newval = Member()
        newval.household = self.household.id
        newval.givenName = "No. \(self.household.others.count + 1)"
        newval.familyName = self.household.head.familyName
        newval.status = .NONCOMMUNING
        newval.father = self.household.head.id
        if let mom = self.household.spouse {
            newval.mother = mom.id
        }
        return newval
    }
}

//struct HouseholdRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdRowView()
//    }
//}
