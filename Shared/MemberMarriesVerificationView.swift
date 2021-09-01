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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
            // TODO
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
