//
//  FamilyDismissedVerificationView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/27/21.
//

import SwiftUI
import PMDataTypes

struct FamilyDismissedVerificationView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: FamilyDismissedAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        Form {
            Text("\(accumulator.dismissalIsPending ? "Dismissal Pending" : "Dismissal") "
                    + "on \(dateFormatter.string(from: accumulator.dateDismissed))")
                .font(.headline)
            if !accumulator.churchFrom.isEmpty {
                EditDisplayView(caption: "Church to:", message: accumulator.churchFrom)
            }
            if !accumulator.authority.isEmpty {
                EditDisplayView(caption: "Authority:", message: accumulator.authority)
            }
            if !accumulator.comment.isEmpty {
                EditDisplayView(caption: "Comment:", message: accumulator.comment)
            }
            Text("Household members")
            Text(document.nameOf(member: document.household(byId: accumulator.householdId).head))
            if let spouseId = document.household(byId: accumulator.householdId).spouse {
                Text(document.nameOf(member: spouseId))
            }
            ForEach(document.household(byId: accumulator.householdId).others, id: \.self) { otherId in
                Text(document.nameOf(member: otherId))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Verify \(accumulator.dismissalIsPending ? "Dismissal Pending" : "Dismissal") "
                        + "on \(dateFormatter.string(from: accumulator.dateDismissed))")
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
            NSLog("FDVV Save")
            let household = document.household(byId: accumulator.householdId)
            dismiss(memberId: household.head)
            if let spouseId = household.spouse {
                dismiss(memberId: spouseId)
            }
            household.others.forEach { dismiss(memberId: $0) }
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
        }) {
            Text("Apply").font(.body)
        }
    }
    
    private func dismiss(memberId: ID) {
        var member = document.member(byId: memberId)
        member.status = accumulator.dismissalIsPending ? .DISMISSAL_PENDING : .DISMISSED
        member.resident = false
        member.transactions.append(accumulator.dismissalTransaction)
        member.dateLastChanged = Date()
        document.update(member: member)
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("FDVV Cancel")
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
            
        }) {
            Text("Cancel").font(.body)
        }
    }
}
