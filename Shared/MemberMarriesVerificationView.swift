//
//  MemberMarriesVerificationView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI
import PMDataTypes

struct MemberMarriesVerificationView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: MemberMarriesMemberAccumulator
    @Binding var linkSelection: WorkflowLink?
    var combined: [ID]

    var body: some View {
        Form {
            Section(header: Text("Marriage Between Two Members - Verification").font(.headline)) {
                EditDisplayView(caption: "Groom:", message: document.nameOf(member: accumulator.groomId))
                EditDisplayView(caption: "Bride:", message: document.nameOf(member: accumulator.brideId))
                DateSelectionView(caption: "Date of wedding:", date: $accumulator.date)
                EditDisplayView(caption: "Address comes from:", message: accumulator.useGroomsAddress ? "Groom" : "Bride")
                Text("Dependents:").italic()
                List {
                    ForEach(accumulator.combinedDependents, id: \.self) { id in
                        Text(document.nameOf(member: id))
                    }
                }
                Text("Note: any changes to bride's name must be applied later.").italic()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        //.navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Marries Member - Verify")
            }
            ToolbarItem(placement: .primaryAction) {
                applyButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }
    
    private var applyButton: some View {
        Button(action: {
            NSLog("MMVV Apply")
            applyChanges()
            accumulator.phase = .reset
        }) {
            Text("Apply").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("MMVV Cancel")
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
            
        }) {
            Text("Cancel").font(.body)
        }
    }
    
    private func applyChanges() {
        var groom = document.member(byId: accumulator.groomId)
        var groomsOldHousehold = document.household(byId: groom.household)
        var bride = document.member(byId: accumulator.brideId)
        var bridesOldHousehold = document.household(byId: bride.household)
        var newHousehold = NormalizedHousehold()
        newHousehold.head = accumulator.groomId
        newHousehold.spouse = accumulator.brideId
        newHousehold.others = accumulator.combinedDependents
        let groomsAddress = document.household(byId: groom.household).address
        let bridesAddress = document.household(byId: bride.household).address
        newHousehold.address = accumulator.useGroomsAddress ? groomsAddress : bridesAddress
        document.add(household: newHousehold)
        groom.household = newHousehold.id
        groom.maritalStatus = .MARRIED
        groom.spouse = bride.fullName()
        groom.dateOfMarriage = accumulator.date
        document.update(member: groom)
        bride.household = newHousehold.id
        bride.maritalStatus = .MARRIED
        bride.spouse = groom.fullName()
        bride.dateOfMarriage = accumulator.date
        document.update(member: bride)
        accumulator.combinedDependents.forEach { otherId in
            var other = document.member(byId: otherId)
            other.household = newHousehold.id
            document.update(member: other)
        }
        if accumulator.groomId == groomsOldHousehold.head {
            document.remove(household: groomsOldHousehold)
        } else {
            let others = groomsOldHousehold.others
            groomsOldHousehold.others = others.filter { $0 != accumulator.groomId }
            document.update(household: groomsOldHousehold)
        }
        if accumulator.brideId == bridesOldHousehold.head {
            document.remove(household: bridesOldHousehold)
        } else {
            let others = bridesOldHousehold.others
            bridesOldHousehold.others = others.filter { $0 != accumulator.brideId }
            document.update(household: bridesOldHousehold)
        }
    }
}

struct MemberMarriesVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        MemberMarriesVerificationView(
            accumulator: Binding.constant(MemberMarriesMemberAccumulator()),
            linkSelection: Binding.constant(nil),
            combined: [mockMember1.id, mockMember2.id, mockMember3.id])
            .environmentObject(mockDocument)
    }
}
