//
//  FamilyJoinWorkflowPhaseView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/5/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct FamilyJoinWorkflowPhaseView: View {
    @Binding var accumulator: FamilyJoinAccumulator
    @Binding var linkSelection: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    NSLog("FJTPV cancel")
                    accumulator.phase = .reset
                    linkSelection = nil //ensure DataWorkflowsView can go again
                    presentationMode.wrappedValue.dismiss() //dismiss FamilyJoinView?
                }) {
                    Text("Cancel").font(.body)
                }
                Spacer()
                Button(action: {
                    accumulator.receptionTransaction.date = self.accumulator.dateReceived
                    switch accumulator.receptionType {
                    case .PROFESSION:
                        accumulator.receptionTransaction.type = .PROFESSION
                        accumulator.receptionTransaction.comment = accumulator.comment
                    case .AFFIRMATION:
                        accumulator.receptionTransaction.type = .RECEIVED
                        accumulator.receptionTransaction.comment = accumulator.comment + " by affirmation"
                    case .TRANSFER:
                        accumulator.receptionTransaction.type = .RECEIVED
                        accumulator.receptionTransaction.comment = accumulator.comment
                    }
                    accumulator.receptionTransaction.church = accumulator.churchFrom
                    accumulator.receptionTransaction.authority = accumulator.authority
                    accumulator.head.transactions = [accumulator.receptionTransaction]
                    accumulator.head.familyName = "Head"
                    accumulator.head.givenName = "of this household"
                    withAnimation(.easeInOut(duration: editAnimationDuration)) {
                        accumulator.phase = .head
                    }
                }) {
                    Text("Save + Continue").font(.body)
                }
            }.padding()
            Form {
                Section {
                    DateSelectionView(caption: "Date received", accumulator: $accumulator)
                    ReceptionTypeView(caption: "Reception type", accumulator: $accumulator)
                    EditTextView(caption: "authority", text: $accumulator.authority)
                    EditTextView(caption: "church from", text: $accumulator.churchFrom)
                    EditTextView(caption: "comment", text: $accumulator.comment)
                }
            }
            .navigationBarTitle("Family Joins - Reception")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct FamilyJoinWorkflowPhaseView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyJoinWorkflowPhaseView(accumulator: Binding.constant(FamilyJoinAccumulator()),
                                       linkSelection: Binding.constant(nil))
    }
}


struct DateSelectionView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var accumulator: FamilyJoinAccumulator

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            DatePicker("",
                       selection: $accumulator.dateReceived,
                       in: ...Date(),
                       displayedComponents: .date).font(.body)
        }
    }
}

struct ReceptionTypeView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var accumulator: FamilyJoinAccumulator

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Picker(selection: $accumulator.receptionType, label: Text("")) {
                ForEach (ReceptionType.allCases, id: \.self) {
                    //Don't forget the tag!
                    Text($0.rawValue).font(.body).tag($0)
                }
            }
        }
    }
}
