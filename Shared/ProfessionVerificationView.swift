//
//  ProfessionVerificationView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI
import PMDataTypes

struct ProfessionVerificationView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: ProfessionAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        Form {
            Section(header: Text("Profession by \(document.nameOf(member: accumulator.memberId))").font(.headline)) {
                ChooseMemberView(caption: "Professing member:",
                                 memberId: $accumulator.memberId)
                DateSelectionView(caption: "Date of profession:", date: $accumulator.date)
                EditTextView(caption: "Comment:", text: $accumulator.comment)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profession - Verify")
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
            NSLog("PVV Save")
            var member = document.member(byId: accumulator.memberId)
            member.status = .COMMUNING
            var transaction = PMDataTypes.Transaction()
            transaction.date = accumulator.date
            transaction.type = .PROFESSION
            transaction.comment = accumulator.comment
            member.transactions.append(transaction)
            member.dateLastChanged = Date()
            document.update(member: member)
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
        }) {
            Text("Apply").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("PVV Cancel")
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
            
        }) {
            Text("Cancel").font(.body)
        }
    }
}
