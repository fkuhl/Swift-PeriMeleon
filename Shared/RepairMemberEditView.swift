//
//  RepairMemberEditView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/16/21.
//

import SwiftUI
import PMDataTypes

struct RepairMemberEditView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var memberId: ID
    @Binding var editing: Bool
    @State private var householdId: ID = ""
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Text("Repair Member \(document.member(byId: memberId).fullName())").font(.title)
                Spacer()
            }
            Text("Edit the household to be stored for this member. If you change it, adjust household(s) as necessary to ensure the links are consistent.")
            Text("Member presently is linked to household '\(document.nameOf(household:  (document.member(byId: memberId)).household))'")
            Text("There is no undo!").font(.headline)
            ChooseHouseholdView(caption: "Household for member",
                                householdId: $householdId)
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
        var member = document.member(byId: memberId)
        member.household = householdId
        member.dateLastChanged = Date()
        document.update(member: member)
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.editing = false
        }
    }
}

//struct RepairMemberEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepairMemberEditView()
//    }
//}
