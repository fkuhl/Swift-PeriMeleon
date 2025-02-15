//
//  CoreMemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/11/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct CoreMemberView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var memberId: ID
    var editable = true
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            List {
                Section {
                    TextAttributeView(caption: "family name:",
                                      text: document.member(byId: memberId).familyName)
                    TextAttributeView(caption: "given name:",
                                      text: document.member(byId: memberId).givenName)
                    if !nugatory(document.member(byId: memberId).middleName) {
                        TextAttributeView(caption: "middle name:",
                                          text: document.member(byId: memberId).middleName)
                    }
                    if !nugatory(document.member(byId: memberId).nameSuffix) {
                        TextAttributeView(caption: "suffix:",
                                          text: document.member(byId: memberId).nameSuffix)
                    }
                    if !nugatory(document.member(byId: memberId).nickname) {
                        TextAttributeView(caption: "nickname:",
                                          text: document.member(byId: memberId).nickname)
                    }
                    if !nugatory(document.member(byId: memberId).previousFamilyName) {
                        TextAttributeView(caption: "prev fam name:",
                                          text: document.member(byId: memberId).previousFamilyName)
                    }
                    if !nugatory(document.member(byId: memberId).title) {
                        TextAttributeView(caption: "title:",
                                          text: document.member(byId: memberId).title)
                    }
                }
                Section {
                    TextAttributeView(caption: "sex:",
                                      text: document.member(byId: memberId).sex.rawValue)
                    if document.member(byId: memberId).dateOfBirth != nil {
                        TextAttributeView(caption: "date of birth:",
                                          text: dateForDisplay(
                                            document.member(byId: memberId).dateOfBirth!))
                    }
                    if document.member(byId: memberId).placeOfBirth != nil {
                        TextAttributeView(caption: "place of birth:",
                                          text: document.member(byId: memberId).placeOfBirth!)
                    }
                    TextAttributeView(caption: "household:",
                                      text: document.nameOf(household: document.member(byId: memberId).household))
                    if document.member(byId: memberId).father != nil {
                        TextAttributeView(caption: "father:",
                                          text: document.nameOf(member: document.member(byId: memberId).father!))
                    }
                    if document.member(byId: memberId).mother != nil {
                        TextAttributeView(caption: "mother:",
                                          text: document.nameOf(member: document.member(byId: memberId).mother!))
                    }
                }
                Section {
                    TextAttributeView(caption: "martial status:",
                                      text: document.member(byId: memberId).maritalStatus.rawValue)
                    if !nugatory(document.member(byId: memberId).spouse) {
                        TextAttributeView(caption: "spouse:",
                                          text: document.member(byId: memberId).spouse)
                    }
                    if document.member(byId: memberId).dateOfMarriage != nil {
                        TextAttributeView(caption: "date of marriage:", text: dateForDisplay(document.member(byId: memberId).dateOfMarriage))
                    }
                    if !nugatory(document.member(byId: memberId).divorce) {
                        TextAttributeView(caption: "divorce:",
                                          text: document.member(byId: memberId).divorce)
                    }
                }
                Section {
                    TextAttributeView(caption: "status:",
                                      text: document.member(byId: memberId).status.rawValue)
                    if !nugatory(document.member(byId: memberId).baptism) {
                        TextAttributeView(caption: "baptism:",
                                          text: document.member(byId: memberId).baptism)
                    }
                    TextAttributeView(caption: "resident:",
                                      text: document.member(byId: memberId).resident ? "yes" : "no")
                    if document.member(byId: memberId).exDirectory {
                        TextAttributeView(caption: "ex-directory:",
                                          text: document.member(byId: memberId).exDirectory ? "yes" : "no")
                    }
                }
                Section {
                    if !nugatory(document.member(byId: memberId).mobilePhone) {
                        TextAttributeView(caption: "mobile phone:",
                                          text: document.member(byId: memberId).mobilePhone)
                    }
                    if !nugatory(document.member(byId: memberId).eMail) {
                        TextAttributeView(caption: "email:",
                                          text: document.member(byId: memberId).eMail)
                    }
                    if !nugatory(document.member(byId: memberId).workPhone) {
                        TextAttributeView(caption: "work phone:",
                                          text: document.member(byId: memberId).workPhone)
                    }
                    if !nugatory(document.member(byId: memberId).workEmail) {
                        TextAttributeView(caption: "work email:",
                                          text: document.member(byId: memberId).workEmail)
                    }
                }
                Section(header: Text("Transactions").font(.callout).italic()) {
                    TransactionsView(member: document.member(byId: memberId))
                }
                if document.member(byId: memberId).services.count > 0 {
                    Section(header: Text("Officer Service").font(.callout).italic()) {
                        ServicesView(member: document.member(byId: memberId))
                    }
                }
                if document.member(byId: memberId).dateLastChanged != nil {
                    Section {
                        TextAttributeView(caption: "date last changed:", text: dateForDisplay(document.member(byId: memberId).dateLastChanged))
                    }
                }
            }
            #if targetEnvironment(macCatalyst)
            .listStyle(GroupedListStyle())
            #endif
        }
        #if targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(document.member(byId: memberId).fullName())
            }
            ToolbarItem(placement: .primaryAction) {
                editButton
            }
        }
    }
    
    private var editButton: some View {
        Group {
            if editable {
                Button(action: {
                    withAnimation(.easeInOut(duration: editAnimationDuration)) { isEditing = true }
                }, label: {
                    Text("Edit").font(.body)
                })
            } else {
                EmptyView()
            }
        }
    }
}
