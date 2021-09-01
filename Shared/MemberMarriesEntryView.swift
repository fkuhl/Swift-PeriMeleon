//
//  MemberMarriesEntryView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI

struct MemberMarriesEntryView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: MemberMarriesMemberAccumulator
    @Binding var linkSelection: WorkflowLink?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                // TODO
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Marries Member - Enter Data")
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
                NSLog("MMEV save")
                // TODO
            }
        }) {
            Text("Save + Continue").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("MMEV cancel")
            accumulator.phase = .reset
            linkSelection = nil
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel").font(.body)
        }
    }
}

struct MemberMarriesEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MemberMarriesEntryView(
            accumulator: Binding.constant(MemberMarriesMemberAccumulator()),
            linkSelection: Binding.constant(nil))
    }
}
