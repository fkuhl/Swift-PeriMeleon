//
//  NewAdditionEntryView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI

struct NewAdditionEntryView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: NewAdditionAccumulator
    @Binding var linkSelection: WorkflowLink?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                ChooseHouseholdView(caption: "Gaining household:",
                                    householdId: $accumulator.member.household)
                EditTextView(caption: "Family name:", text: $accumulator.member.familyName)
                EditTextView(caption: "Given name:", text: $accumulator.member.givenName)
                EditOptionalTextView(caption: "Middle name:", text: $accumulator.member.middleName)
                EditOptionalTextView(caption: "Nickname, if any:", text: $accumulator.member.nickname)
                EditOptionalTextView(caption: "suffix:", text: $accumulator.member.nameSuffix)
                EditSexView(caption: "sex:", sex: $accumulator.member.sex)
                DateSelectionView(caption: "Birthdate:", date: $accumulator.birthdate)
                EditOptionalTextView(caption: "Birthplace:", text: $accumulator.member.placeOfBirth)
                EditTextView(caption: "comment", text: $accumulator.comment)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Addition - Enter Data")
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
                NSLog("NAEV save")
                let household = document.household(byId: accumulator.member.household)
                accumulator.member.father = household.head
                if let spouse = household.spouse {
                    accumulator.member.mother = spouse
                }
                accumulator.member.status = .NONCOMMUNING
                accumulator.phase = .verification
            }
        }) {
            Text("Save + Continue").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("NAEV cancel")
            accumulator.phase = .reset
            linkSelection = nil
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel").font(.body)
        }
    }
}

struct NewAdditionEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewAdditionEntryView(
            accumulator: Binding.constant(NewAdditionAccumulator()),
            linkSelection: Binding.constant(nil))
    }
}
