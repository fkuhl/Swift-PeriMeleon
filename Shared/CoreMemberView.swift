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
    @ObservedObject var document = PeriMeleonDocument.shared
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
                    if document.member(byId: memberId).middleName != nil {
                        TextAttributeView(caption: "middle name:",
                                          text: document.member(byId: memberId).middleName)
                    }
                    if document.member(byId: memberId).previousFamilyName != nil {
                        TextAttributeView(caption: "prev fam name:",
                                          text: document.member(byId: memberId).previousFamilyName)
                    }
                    if document.member(byId: memberId).nameSuffix != nil {
                        TextAttributeView(caption: "suffix:",
                                          text: document.member(byId: memberId).nameSuffix)
                    }
                    if document.member(byId: memberId).title != nil {
                        TextAttributeView(caption: "title:",
                                          text: document.member(byId: memberId).title)
                    }
                    if document.member(byId: memberId).nickname != nil {
                        TextAttributeView(caption: "nickname:",
                                          text: document.member(byId: memberId).nickname)
                    }
                    TextAttributeView(caption: "sex:",
                                      text: document.member(byId: memberId).sex.rawValue)
                    TextAttributeView(caption: "status:",
                                      text: document.member(byId: memberId).status.rawValue)
                }
                Section {
                    TextAttributeView(caption: "resident:",
                                      text: document.member(byId: memberId).resident ? "yes" : "no")
                    TextAttributeView(caption: "ex-directory:",
                                      text: document.member(byId: memberId).exDirectory ? "yes" : "no")
                    if document.member(byId: memberId).dateOfBirth != nil {
                        TextAttributeView(caption: "date of birth:",
                                          text: dateForDisplay(
                                            document.member(byId: memberId).dateOfBirth!))
                    }
                    if document.member(byId: memberId).placeOfBirth != nil {
                        TextAttributeView(caption: "place of birth:",
                                          text: document.member(byId: memberId).placeOfBirth!)
                    }
                    if document.member(byId: memberId).baptism != nil {
                        TextAttributeView(caption: "baptism:",
                                          text: document.member(byId: memberId).baptism)
                    }
                    TextAttributeView(caption: "household:",
                                      text: document.nameOf(household: document.member(byId: memberId).household))
                    TextAttributeView(caption: "martial status:",
                                      text: document.member(byId: memberId).maritalStatus.rawValue)
                    if document.member(byId: memberId).spouse != nil {
                        TextAttributeView(caption: "spouse:",
                                          text: document.member(byId: memberId).spouse)
                    }
                    if document.member(byId: memberId).dateOfMarriage != nil {
                        TextAttributeView(caption: "date of marriage:", text: dateForDisplay(document.member(byId: memberId).dateOfMarriage))
                    }
                    if document.member(byId: memberId).divorce != nil {
                        TextAttributeView(caption: "divorce:",
                                          text: document.member(byId: memberId).divorce)
                    }
                }
                Section {
                    if document.member(byId: memberId).father != nil {
                        TextAttributeView(caption: "father:",
                                          text: document.nameOf(member: document.member(byId: memberId).father!))
                    }
                    if document.member(byId: memberId).mother != nil {
                        TextAttributeView(caption: "mother:",
                                          text: document.nameOf(member: document.member(byId: memberId).mother!))
                    }
                    if document.member(byId: memberId).eMail != nil {
                        TextAttributeView(caption: "email:",
                                          text: document.member(byId: memberId).eMail)
                    }
                    if document.member(byId: memberId).workEmail != nil {
                        TextAttributeView(caption: "work email:",
                                          text: document.member(byId: memberId).workEmail)
                    }
                    if document.member(byId: memberId).mobilePhone != nil {
                        TextAttributeView(caption: "mobile phone:",
                                          text: document.member(byId: memberId).mobilePhone)
                    }
                    if document.member(byId: memberId).workPhone != nil {
                        TextAttributeView(caption: "work phone:",
                                          text: document.member(byId: memberId).workPhone)
                    }
                }
                if document.member(byId: memberId).dateLastChanged != nil {
                    TextAttributeView(caption: "date last changed:", text: dateForDisplay(document.member(byId: memberId).dateLastChanged))
                }
                Section(header: Text("Transactions").font(.callout).italic()) {
                    TransactionsView(member: document.member(byId: memberId))
                }
                if document.member(byId: memberId).services.count > 0 {
                    Section(header: Text("Officer Service").font(.callout).italic()) {
                        ServicesView(member: document.member(byId: memberId))
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
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
