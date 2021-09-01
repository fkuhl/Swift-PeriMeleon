//
//  MemberMarriesVerificationView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI

struct MemberMarriesVerificationView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: MemberMarriesMemberAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        Form {
            // TODO
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("***fix this*** - Verify")
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
            NSLog("MMVV Save")
            // TODO
        }) {
            Text("Apply").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("NAVV Cancel")
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
            
        }) {
            Text("Cancel").font(.body)
        }
    }
}
