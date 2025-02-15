//
//  ProfessionEntryView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI

struct ProfessionEntryView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: ProfessionAccumulator
    @Binding var linkSelection: WorkflowLink?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
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
                Text("Profession - Enter Data")
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
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                NSLog("PEV continue")
                accumulator.phase = .verification
            }
        }) {
            Text("Continue").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("PEV cancel")
            accumulator.phase = .reset
            linkSelection = nil
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel").font(.body)
        }
    }
}

struct ProfessionEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ProfessionEntryView(
            accumulator: Binding.constant(ProfessionAccumulator()),
            linkSelection: Binding.constant(nil))
    }
}
