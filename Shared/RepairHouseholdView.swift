//
//  RepairHouseholdView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/16/21.
//

import SwiftUI
import PMDataTypes

/**
 This code (as of 1.4.0) is not being used. I'm leaving it here because I may need later to take
 the approach of a separate repair action. In 1.4.0 a household can be edited completely.
 */

struct RepairHouseholdView: View {
    @State private var householdId: ID = ""
    @State var editing = false
    
    var body: some View {
        VStack {
            if !editing {
                chooseHousehold
                    .transition(.move(edge: .trailing))
            } else {
                RepairHouseholdEditView(householdId: householdId, editing: $editing)
                    .transition(.move(edge: .trailing))
            }
            Spacer()
        }
    }
    
    private var chooseHousehold: some View {
        Form {
            Text("Choose household to repair").font(.title)
            Text("This is to be used only to maintain the data, i.e., to correct a problem. It is NOT to be used for any normal membership transaction. If you edit the members of a household, be sure to make the Member entris consistent.").font(.headline)
            ChooseHouseholdView(caption: "Household to be repaired:", householdId: $householdId)
            HStack {
                Spacer()
                SolidButton(text: "Edit household", action: edit)
                    .disabled(householdId.count <= 0)
                Spacer()
            }.padding()
        }
    }
    
    private func edit() {
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.editing = true
        }
    }
}

struct RepairHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        RepairHouseholdView()
    }
}
