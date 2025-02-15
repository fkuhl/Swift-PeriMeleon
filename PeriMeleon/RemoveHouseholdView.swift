//
//  RemoveHouseholdView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/11/21.
//

import SwiftUI
import PMDataTypes

struct RemoveHouseholdView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var householdId: ID = ""
    @State private var membersOfThisHousehold = [ID]()
    @State private var removalState: RemoveHouseholdState = .enteringData
    @State private var showingSheet = false

    var body: some View {
        Form {
            Text("Remove household").font(.title)
            Text("This is to be used only to maintain the data, i.e., to correct a problem. It is NOT to be used for any normal membership transaction.").font(.headline)
            ChooseHouseholdView(caption: "Household to be removed:", householdId: $householdId)
            HStack {
                Spacer()
                SolidButton(text: "Check removal", action: checkRemoval)
                    .disabled(householdId.count <= 0)
                Spacer()
            }.padding()
        }
        .sheet(isPresented: $showingSheet) {
            RemoveHouseholdSheet(householdId: $householdId,
                              membersOfThisHousehold: $membersOfThisHousehold,
                              removalState: $removalState,
                              showingSheet: $showingSheet).environmentObject(document)
        }
    }
    
    func checkRemoval() {
        removalState = .enteringData
        membersOfThisHousehold = [ID]()
        let household = document.household(byId: householdId)
        let head = document.member(byId: household.head)
        if head.household == householdId { membersOfThisHousehold.append(household.head) }
        if let spouseId = household.spouse {
            let spouse = document.member(byId: spouseId)
            if spouse.household == householdId {
                membersOfThisHousehold.append(spouseId)
            }
        }
        for otherId in household.others {
            let other = document.member(byId: otherId)
            if other.household == householdId {
                membersOfThisHousehold.append(otherId)
            }
        }
        removalState = (membersOfThisHousehold.count > 0)
        ? .memberInThisHousehold
        : .readyToBeRemoved
        showingSheet = true
    }
}

struct RemoveHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveHouseholdView()
    }
}
