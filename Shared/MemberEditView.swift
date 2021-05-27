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
    func store(member: Member) -> Void
}

protocol MemberCancelDelegate {
    func cancel() -> Void
}

struct MemberEditView: View {
    @Binding var document: PeriMeleonDocument
    @State var member: Member
    var memberEditDelegate: MemberEditDelegate
    var memberCancelDelegate: MemberCancelDelegate
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            topButtons
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
                    EditOptionalTextView(caption: "place of birth:", text: $member.placeOfBirth)
                    EditOptionalTextView(caption: "baptism:", text: $member.baptism)
                    EditDisplayView(caption: "household:", message: "Change household via 'Change member's household.'")
                }
                Section {
                    EditMaritalStatusView(caption: "marital status:", maritalStatus: $member.maritalStatus)
                    EditOptionalTextView(caption: "spouse:", text: $member.spouse)
                    EditOptionalDateView(caption: "date of marriage:", date: $member.dateOfMarriage)
                    EditOptionalTextView(caption: "divorce:", text: $member.divorce)
                }
                Section {
                    EditOptionalParentView(document: $document,
                                           caption: "father",
                                           sex: .MALE,
                                           parentId: $member.father,
                                           title: "Father of \(member.fullName())")
                    EditOptionalParentView(document: $document,
                                           caption: "mother",
                                           sex: .FEMALE,
                                           parentId: $member.mother,
                                           title: "Mother of \(member.fullName())")
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
            }
        }
        .navigationBarTitle(member.fullName())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var topButtons: some View {
        HStack {
            Button(action: {
                NSLog("MEV cancel")
                withAnimation(.easeInOut(duration: editAnimationDuration)) { isEditing = false
                }
                self.memberCancelDelegate.cancel()
            }) {
                Text("Cancel").font(.body)
            }
            Spacer()
            Button(action: {
                NSLog("MEV Save Member \(member.fullName())")
                withAnimation(.easeInOut(duration: editAnimationDuration)) {
                    isEditing = false
                }
                memberEditDelegate.store(member: member)
            }) {
                Text("Save Member").font(.body)
            }
        }.padding()
    }
}

//struct MemberEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberEditView(showingEdit: .constant(false), member: member1)
//    }
//}
