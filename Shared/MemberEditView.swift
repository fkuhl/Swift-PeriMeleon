//
//  MemberEditView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/12/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

protocol MemberEditDelegate {
    var document: Binding<PeriMeleonDocument> { get }
    func store(member: Member, in household: Binding<NormalizedHousehold>?) -> Void
}

protocol MemberCancelDelegate {
    func cancel() -> Void
}

struct MemberEditView: View {
    @Binding var document: PeriMeleonDocument
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    //@EnvironmentObject var accumulator: FamilyAccumulator
    @State var member: Member
    var memberEditDelegate: MemberEditDelegate
    var memberCancelDelegate: MemberCancelDelegate
    var closingAction: (_ member: Member, _ delegate: MemberEditDelegate) -> Void
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    NSLog("MEV cancel")
                    isEditing = false
                    self.memberCancelDelegate.cancel()
                }) {
                    Text("Cancel").font(.body)
                }
                Spacer()
                Button(action: {
                    //NSLog("MEV save+finish household \(nameOfHousehold(self.member.household))")
                    NSLog("MEV save+finish household \(self.member.household)")
                    isEditing = false
                    self.closingAction(self.member, self.memberEditDelegate)
                }) {
                    Text("Save + Finish").font(.body)
                }
            }.padding()
            Form {
                Section { //Section to group in sets of <= 10
                    EditTextView(caption: "family name:", text: $member.familyName)
                    EditTextView(caption: "given name:", text: $member.givenName)
                    EditOptionalTextView(caption: "middle name:", text: $member.middleName)
                    EditOptionalTextView(caption: "prev fam name:", text: $member.previousFamilyName)
                    EditOptionalTextView(caption: "suffix:", text: $member.nameSuffix)
                    EditOptionalTextView(caption: "title:", text: $member.title)
                    EditOptionalTextView(caption: "nickname:", text: $member.nickname)
                    EditSexView(caption: "sex:", sex: $member.sex)
                    EditMemberStatusView(caption: "status:", memberStatus: $member.status)
                }
                Section {
                    EditBoolView(caption: "resident:", choice: $member.resident)
                    EditBoolView(caption: "ex-directory:", choice: $member.exDirectory)
                    EditOptionalDateView(caption: "date of birth:", date: $member.dateOfBirth)
                    EditDateButton(caption: "date of birth:", date: $member.dateOfBirth)
                    EditOptionalTextView(caption: "place of birth:", text: $member.placeOfBirth)
                    EditOptionalTextView(caption: "baptism:", text: $member.baptism)
                    EditDisplayView(caption: "household:", message: "Change household via 'Change member's household.'")
                }
                Section {
                    EditMaritalStatusView(caption: "marital status:", maritalStatus: $member.maritalStatus)
                    EditOptionalTextView(caption: "spouse:", text: $member.spouse)
                    EditOptionalDateView(caption: "date of marriage:", date: $member.dateOfMarriage)
                    EditDateButton(caption: "date of marriage:", date: $member.dateOfMarriage)
                    EditOptionalTextView(caption: "divorce:", text: $member.divorce)
                }
                Section {
                    EditOptionalParentView(document: $document, caption: "father", sex: .MALE, parentId: $member.father)
                    EditOptionalParentView(document: $document, caption: "mother", sex: .FEMALE, parentId: $member.mother)
                    EditOptionalTextView(caption: "email:", text: $member.eMail)
                    EditOptionalTextView(caption: "work email:", text: $member.workEmail)
                    EditOptionalTextView(caption: "mobile phone:", text: $member.mobilePhone)
                    EditOptionalTextView(caption: "work phone:", text: $member.workPhone)
                }
                Section(header: Text("Transactions").font(.callout).italic()) {
                    TransactionsEditView(member: $member)
                    TransactionsEditAddView(member: $member)
                }
                Section(header: Text("Officer Service").font(.callout).italic()) {
                    ServicesEditView(member: $member)
                    ServicesEditAddView(member: $member)
                }
                EditOptionalDateView(caption: "date last changed:", date: $member.dateLastChanged)
                EditDateButton(caption: "date last changed:", date: $member.dateLastChanged)
            }
        }
    }
}

//struct MemberEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberEditView(showingEdit: .constant(false), member: member1)
//    }
//}
