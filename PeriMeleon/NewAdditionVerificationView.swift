//
//  NewAdditionVerificationView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI
import PMDataTypes

struct NewAdditionVerificationView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: NewAdditionAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        Form {
            Section(header: Text("Adding \(accumulator.member.givenName) \(accumulator.member.familyName) to household \(document.nameOf(household: accumulator.member.household))").font(.headline)) {
                Group {
                    EditTextView(caption: "Family name:", text: $accumulator.member.familyName)
                    EditTextView(caption: "Given name:", text: $accumulator.member.givenName)
                    EditOptionalTextView(caption: "Middle name:", text: $accumulator.member.middleName)
                    EditOptionalTextView(caption: "Nickname, if any:", text: $accumulator.member.nickname)
                    EditSexView(caption: "Sex:", sex: $accumulator.member.sex)
                    DateSelectionView(caption: "Birthdate:", date: $accumulator.birthdate)
                    EditOptionalTextView(caption: "Birthplace:", text: $accumulator.member.placeOfBirth)
                    EditOptionalParentView(caption: "Father:",
                                           sex: .MALE,
                                           parentId: $accumulator.member.father,
                                           title: "")
                    EditOptionalParentView(caption: "Mother:",
                                           sex: .FEMALE,
                                           parentId: $accumulator.member.mother,
                                           title: "")
                    EditMemberStatusView(caption: "Status:", memberStatus: $accumulator.member.status)
                }
                Group { //gotta love the 10-item limit
                    EditTextView(caption: "Comment:", text: $accumulator.comment)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Addition of \(accumulator.member.givenName) \(accumulator.member.familyName) - Verify")
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
            NSLog("NAVV Save")
            accumulator.member.dateOfBirth = accumulator.birthdate
            var transaction = PMDataTypes.Transaction()
            transaction.date = accumulator.birthdate
            transaction.type = .BIRTH
            transaction.comment = accumulator.comment
            accumulator.member.transactions.append(transaction)
            document.add(member: accumulator.member)
            var household = document.household(byId: accumulator.member.household)
            household.others.append(accumulator.member.id)
            document.update(household: household)
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
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
