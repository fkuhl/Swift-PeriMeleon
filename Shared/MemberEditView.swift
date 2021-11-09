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
    func store(member: Member) -> Void
}

protocol MemberCancelDelegate {
    func cancel() -> Void
}

struct MemberEditView: View {
    @State var member: Member
    var memberEditDelegate: MemberEditDelegate
    var memberCancelDelegate: MemberCancelDelegate
    @Binding var isEditing: Bool


    var body: some View {
        Form {
            Section { //Section to group in sets of <= 10
                EditTextView(caption: "family name:", text: $member.familyName)
                EditTextView(caption: "given name:", text: $member.givenName)
                EditOptionalTextView(caption: "middle name:", text: $member.middleName)
                EditOptionalTextView(caption: "suffix:", text: $member.nameSuffix)
                EditOptionalTextView(caption: "nickname:", text: $member.nickname)
                EditOptionalTextView(caption: "prev fam name:", text: $member.previousFamilyName)
                EditOptionalTextView(caption: "title:", text: $member.title)
            }
            Section {
                EditSexView(caption: "sex:", sex: $member.sex)
                EditOptionalDateView(caption: "date of birth:", date: $member.dateOfBirth)
                EditOptionalTextView(caption: "place of birth:", text: $member.placeOfBirth)
                EditDisplayView(caption: "household:", message: "Change household via 'Change member's household.'")
                EditOptionalParentView(caption: "father",
                                       sex: .MALE,
                                       parentId: $member.father,
                                       title: "Father of \(member.fullName())")
                EditOptionalParentView(caption: "mother",
                                       sex: .FEMALE,
                                       parentId: $member.mother,
                                       title: "Mother of \(member.fullName())")
                }
            Section {
                EditMaritalStatusView(caption: "marital status:", maritalStatus: $member.maritalStatus)
                EditOptionalTextView(caption: "spouse:", text: $member.spouse)
                EditOptionalDateView(caption: "date of marriage:", date: $member.dateOfMarriage)
                EditOptionalTextView(caption: "divorce:", text: $member.divorce)
            }
            Section {
                EditMemberStatusView(caption: "status:", memberStatus: $member.status)
                EditOptionalTextView(caption: "baptism:", text: $member.baptism)
                EditBoolView(caption: "resident:", choice: $member.resident)
                EditBoolView(caption: "ex-directory:", choice: $member.exDirectory)
            }
            
            Section {
                EditOptionalTextView(caption: "mobile phone:", text: $member.mobilePhone)
                EditOptionalTextView(caption: "email:", text: $member.eMail)
                EditOptionalTextView(caption: "work phone:", text: $member.workPhone)
                EditOptionalTextView(caption: "work email:", text: $member.workEmail)
            }
            Section(header: Text("Transactions").font(.callout).italic()) {
                TransactionsEditView(member: $member)
                TransactionsEditAddView(member: $member)
                if member.transactions.count > 0 {
#if targetEnvironment(macCatalyst)
                    Text("To delete a transaction, swipe its row. (Swipe, rather than click and drag.)").font(.caption).italic()
#else
                    Text("To delete a transaction, swipe its row.").font(.caption).italic()
#endif
                }
            }
            Section(header: Text("Officer Service").font(.callout).italic()) {
                ServicesEditView(member: $member)
                ServicesEditAddView(member: $member)
                if member.services.count > 0 {
#if targetEnvironment(macCatalyst)
                    Text("To delete a service record, swipe its row. (Swipe, rather than click and drag.)").font(.caption).italic()
#else
                    Text("To delete a service record, swipe its row.").font(.caption).italic()
#endif
                }
            }
            Section {
                EditOptionalDateView(caption: "date last changed:", date: $member.dateLastChanged)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(member.fullName())
            }
            ToolbarItem(placement: .primaryAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("MEV cancel")
            withAnimation(.easeInOut(duration: editAnimationDuration)) { isEditing = false
            }
            self.memberCancelDelegate.cancel()
        }) {
            Text("Cancel").font(.body)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            NSLog("MEV Save Member \(member.fullName())")
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                isEditing = false
            }
            memberEditDelegate.store(member: member)
        }) {
            Text("Save Member").font(.body)
        }
    }
}

