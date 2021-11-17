//
//  RepairHouseholdEditView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/16/21.
//

import SwiftUI
import PMDataTypes

struct RepairHouseholdEditView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var householdId: ID
    @Binding var editing: Bool
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            HStack {
                Spacer()
//                Text("Repair Household \(document.household(byId: householdId).name)").font(.title)
                Spacer()
            }
            Text("Edit the members of this . If you change it, adjust household(s) as necessary to ensure the links are consistent.")
//            Text("Member presently is linked to household '\(document.nameOf(household:  (document.member(byId: memberId)).household))'")
            Text("There is no undo!").font(.headline)
//            ChooseHouseholdView(caption: "Household for member",
//                                householdId: $householdId)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: cancel).padding()
                SolidButton(text: "Save household", action: { showingAlert = true } ).padding()
                Spacer()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Save household?"),
                  message: Text("There is no undo!"),
                  primaryButton: .destructive(Text("Save")) { apply() },
                  secondaryButton: .cancel()
            )
        }
    }
    
    private func cancel() {
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.editing = false
        }
    }
    
    private func apply() {
//        var member = document.member(byId: memberId)
//        member.household = householdId
//        document.update(member: member)
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.editing = false
        }
    }
}

//struct RepairHouseholdEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepairHouseholdEditView()
//    }
//}
