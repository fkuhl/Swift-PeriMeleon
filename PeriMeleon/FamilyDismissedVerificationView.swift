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
            Section(header: Text(
                        "\(accumulator.dismissalIsPending ? "Dismissal Pending" : "Dismissal") "
                        + "on \(dateFormatter.string(from: accumulator.dateDismissed))")
                        .font(.headline)) {
                if !accumulator.churchTo.isEmpty {
                    EditDisplayView(caption: "Church to:", message: accumulator.churchTo)
                }
                if !accumulator.authority.isEmpty {
                    EditDisplayView(caption: "Authority:", message: accumulator.authority)
                }
                if !accumulator.comment.isEmpty {
                    EditDisplayView(caption: "Comment:", message: accumulator.comment)
                }
            }
            Section(header: Text("Household members:").font(.headline)) {
                Text(document.nameOf(member: document.household(byId: accumulator.householdId).head))
                if let spouseId = document.household(byId: accumulator.householdId).spouse {
                    Text(document.nameOf(member: spouseId))
                }
                ForEach(document.household(byId: accumulator.householdId).others, id: \.self) { otherId in
                    Text(document.nameOf(member: otherId))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Family \(accumulator.dismissalIsPending ? "Dismissal Pending" : "Dismissal") - Verify")
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
        var newTransaction = accumulator.dismissalTransaction
        var member = document.member(byId: memberId)
        if member.status == .NONCOMMUNING {
            if let comment = newTransaction.comment {
                newTransaction.comment = comment + " Noncommuning"
            } else {
                newTransaction.comment = "Noncommuning"
            }
        }
        member.status = accumulator.dismissalIsPending ? .DISMISSAL_PENDING : .DISMISSED
        member.resident = false
        member.transactions.append(newTransaction)
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
