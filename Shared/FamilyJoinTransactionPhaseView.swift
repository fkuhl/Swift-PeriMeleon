//
//  FamilyJoinTransactionPhaseView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/5/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct FamilyJoinTransactionPhaseView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var accumulator: FamilyAccumulator
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
//                    NSLog("MEV cancel")
//                    withAnimation(.easeInOut(duration: MemberView.editAnimationDuration)) { isEditing = false
//                    }
//                    self.memberCancelDelegate.cancel()
                }) {
                    Text("Cancel").font(.body)
                }
                Spacer()
                Button(action: {
                    self.accumulator.receptionTransaction.date = self.accumulator.dateReceived
                    switch self.accumulator.receptionType {
                    case .PROFESSION:
                        self.accumulator.receptionTransaction.type = .PROFESSION
                        self.accumulator.receptionTransaction.comment = self.accumulator.comment
                    case .AFFIRMATION:
                        self.accumulator.receptionTransaction.type = .RECEIVED
                        self.accumulator.receptionTransaction.comment = self.accumulator.comment + " by affirmation"
                    case .TRANSFER:
                        self.accumulator.receptionTransaction.type = .RECEIVED
                        self.accumulator.receptionTransaction.comment = self.accumulator.comment
                    }
                    self.accumulator.receptionTransaction.church = self.accumulator.churchFrom
                    self.accumulator.receptionTransaction.authority = self.accumulator.authority
                    self.accumulator.head.transactions = [self.accumulator.receptionTransaction]
                    self.accumulator.head.familyName = "Head"
                    self.accumulator.head.givenName = "of this household"
                    self.accumulator.phase = .head
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save + Continue").font(.body)
                }
            }.padding()
            Form {
                Section {
                    DateSelectionView(caption: "Date received")
                    ReceptionTypeView(caption: "Reception type")
                    EditTextView(caption: "authority", text: $accumulator.authority)
                    EditTextView(caption: "church from", text: $accumulator.churchFrom)
                    EditTextView(caption: "comment", text: $accumulator.comment)
                }
            }
            .navigationBarTitle("Family Joins - Reception")
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct FamilyJoinTransactionPhaseView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyJoinTransactionPhaseView()
    }
}


struct DateSelectionView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @EnvironmentObject var accumulator: FamilyAccumulator

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
//        .onAppear() {
//            NSLog("DSV onApp")
//        }
//        .onDisappear() {
//            NSLog("DSV onDis")
//        }
    }
}

struct ReceptionTypeView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @EnvironmentObject var accumulator: FamilyAccumulator

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
