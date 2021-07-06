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
    @EnvironmentObject var model: Model
    var householdId: ID
    
    var body: some View {
        NavigationLink(destination: HouseholdView(householdId: householdId,
                                                  spouseFactory: SpouseFactory(
                                                    model: model,
                                                    householdId: householdId),
                                                  otherFactory: OtherFactory(
                                                    model: model,
                                                    householdId: householdId))) {
            Text(model.nameOf(household: householdId)).font(.body)
        }
    }
}

fileprivate class SpouseFactory: HouseholdMemberFactoryDelegate {
    var model: Model
    let householdId: ID
    
    init(model: Model, householdId: ID) {
        self.model = model
        self.householdId = householdId
    }
    
    func make() -> Member {
        let household = model.household(byId: householdId)
        let head = model.member(byId: household.head)
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
    var model: Model
    let householdId: ID
    
    init(model: Model, householdId: ID) {
        self.model = model
        self.householdId = householdId
    }
    
    func make() -> Member {
        let household = model.household(byId: householdId)
        var newval = Member()
        newval.household = household.id
        newval.givenName = "No. \(household.others.count + 1)"
        newval.familyName = model.member(byId: household.head).familyName
        newval.status = .NONCOMMUNING
        newval.father = model.member(byId: household.head).id
        if let mom = household.spouse {
            newval.mother = model.member(byId: mom).id
        }
        return newval
    }
}
