//
//  RemoveHouseholdSheet.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/11/21.
//

import SwiftUI
import PMDataTypes

struct RemoveHouseholdSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var householdId: ID
    @Binding var membersOfThisHousehold: [ID]
    @Binding var removalState: RemoveHouseholdState
    @Binding var showingSheet: Bool
    
    var body: some View {
        switch removalState {
        case .enteringData:
            Form {
                Text("This should never appear!")
                merelyDismiss
            }
        case .memberInThisHousehold:
            memberInThisHousehold
        case .readyToBeRemoved:
            readyToBeRemoved
        }
    }
    
    /// There are members in this household; can't remove.
    private var memberInThisHousehold: some View {
        Form {
            Text("The following are members of household '\(document.nameOf(household: householdId))'; they must be moved to other households before this household can be removed.").font(.headline)
            List {
                ForEach(membersOfThisHousehold, id: \.self) { suspect in
                    Text(document.nameOf(member: suspect)).font(.subheadline)
                }
            }
            merelyDismiss
        }
    }
    
    /// Apparent members of this household are actually members of other households.
    private var readyToBeRemoved: some View {
        Form {
            Text("The apparent members of this household are actually members of other households, so household '\(document.nameOf(household: householdId))' can be removed.")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                    NSLog("canceling")
                    presentationMode.wrappedValue.dismiss()
                })
                Spacer()
                SolidButton(text: "Remove Household", action: removeAndDismiss)
                Spacer()
            }
        }
    }
    
    private func removeAndDismiss() {
        NSLog("removing")
        let household = document.household(byId: householdId)
        NSLog("removing entry for household '\(document.nameOf(household: householdId))'")
        document.remove(household: household)
        presentationMode.wrappedValue.dismiss()
    }

    private var merelyDismiss: some View {
        HStack {
            Spacer()
            SolidButton(text: "Dismiss", action: {
                presentationMode.wrappedValue.dismiss() })
            Spacer()
        }.padding()
    }
}

//struct RemoveHouseholdSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        RemoveHouseholdSheet()
//    }
//}
