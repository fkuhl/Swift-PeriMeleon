//
//  FamilyDismissedTransactionView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/27/21.
//

import SwiftUI

struct FamilyDismissedTransactionView: View {
    @Binding var accumulator: FamilyDismissedAccumulator
    @Binding var linkSelection: WorkflowLink?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                ChooseHouseholdView(caption: "Household to be dismissed:",
                                    householdId: $accumulator.householdId)
                EditBoolView(caption: "Dismissal is pending",
                             choice: $accumulator.dismissalIsPending)
                DateSelectionView(caption: "Date dismissed", date: $accumulator.dateDismissed)
                EditTextView(caption: "authority", text: $accumulator.authority)
                EditTextView(caption: "church to", text: $accumulator.churchTo)
                EditTextView(caption: "comment", text: $accumulator.comment)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Family Dismissed - Transaction")
            }
            ToolbarItem(placement: .primaryAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            accumulator.dismissalTransaction.date = self.accumulator.dateDismissed
            accumulator.dismissalTransaction.type = accumulator.dismissalIsPending ?
                .DISMISSAL_PENDING : .DISMISSED
            accumulator.dismissalTransaction.church = accumulator.churchTo
            accumulator.dismissalTransaction.authority = accumulator.authority
            accumulator.dismissalTransaction.comment = accumulator.comment
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                accumulator.phase = .verification
            }
        }) {
            Text("Continue").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("FJTPV cancel")
            accumulator.phase = .reset
            linkSelection = nil //ensure DataWorkflowsView can go again
            presentationMode.wrappedValue.dismiss() //dismiss FamilyJoinView?
        }) {
            Text("Cancel").font(.body)
        }
    }
}

struct FamilyDismissedTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyDismissedTransactionView(
            accumulator: Binding.constant(FamilyDismissedAccumulator()),
            linkSelection: Binding.constant(nil))
    }
}
