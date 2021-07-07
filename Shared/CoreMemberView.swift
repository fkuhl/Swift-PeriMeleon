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
    @ObservedObject var model: Model = .shared
    var memberId: ID
    var editable = true
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            List {
                Section {
                    TextAttributeView(caption: "family name:",
                                      text: model.member(byId: memberId).familyName)
                    TextAttributeView(caption: "given name:",
                                      text: model.member(byId: memberId).givenName)
                    if model.member(byId: memberId).middleName != nil {
                        TextAttributeView(caption: "middle name:",
                                          text: model.member(byId: memberId).middleName)
                    }
                    if model.member(byId: memberId).previousFamilyName != nil {
                        TextAttributeView(caption: "prev fam name:",
                                          text: model.member(byId: memberId).previousFamilyName)
                    }
                    if model.member(byId: memberId).nameSuffix != nil {
                        TextAttributeView(caption: "suffix:",
                                          text: model.member(byId: memberId).nameSuffix)
                    }
                    if model.member(byId: memberId).title != nil {
                        TextAttributeView(caption: "title:",
                                          text: model.member(byId: memberId).title)
                    }
                    if model.member(byId: memberId).nickname != nil {
                        TextAttributeView(caption: "nickname:",
                                          text: model.member(byId: memberId).nickname)
                    }
                    TextAttributeView(caption: "sex:",
                                      text: model.member(byId: memberId).sex.rawValue)
                    TextAttributeView(caption: "status:",
                                      text: model.member(byId: memberId).status.rawValue)
                }
                Section {
                    TextAttributeView(caption: "resident:",
                                      text: model.member(byId: memberId).resident ? "yes" : "no")
                    TextAttributeView(caption: "ex-directory:",
                                      text: model.member(byId: memberId).exDirectory ? "yes" : "no")
                    if model.member(byId: memberId).dateOfBirth != nil {
                        TextAttributeView(caption: "date of birth:",
                                          text: dateForDisplay(
                                            model.member(byId: memberId).dateOfBirth!))
                    }
                    if model.member(byId: memberId).placeOfBirth != nil {
                        TextAttributeView(caption: "place of birth:",
                                          text: model.member(byId: memberId).placeOfBirth!)
                    }
                    if model.member(byId: memberId).baptism != nil {
                        TextAttributeView(caption: "baptism:",
                                          text: model.member(byId: memberId).baptism)
                    }
                    TextAttributeView(caption: "household:",
                                      text: model.nameOf(household: model.member(byId: memberId).household))
                    TextAttributeView(caption: "martial status:",
                                      text: model.member(byId: memberId).maritalStatus.rawValue)
                    if model.member(byId: memberId).spouse != nil {
                        TextAttributeView(caption: "spouse:",
                                          text: model.member(byId: memberId).spouse)
                    }
                    if model.member(byId: memberId).dateOfMarriage != nil {
                        TextAttributeView(caption: "date of marriage:", text: dateForDisplay(model.member(byId: memberId).dateOfMarriage))
                    }
                    if model.member(byId: memberId).divorce != nil {
                        TextAttributeView(caption: "divorce:",
                                          text: model.member(byId: memberId).divorce)
                    }
                }
                Section {
                    if model.member(byId: memberId).father != nil {
                        TextAttributeView(caption: "father:",
                                          text: model.nameOf(member: model.member(byId: memberId).father!))
                    }
                    if model.member(byId: memberId).mother != nil {
                        TextAttributeView(caption: "mother:",
                                          text: model.nameOf(member: model.member(byId: memberId).mother!))
                    }
                    if model.member(byId: memberId).eMail != nil {
                        TextAttributeView(caption: "email:",
                                          text: model.member(byId: memberId).eMail)
                    }
                    if model.member(byId: memberId).workEmail != nil {
                        TextAttributeView(caption: "work email:",
                                          text: model.member(byId: memberId).workEmail)
                    }
                    if model.member(byId: memberId).mobilePhone != nil {
                        TextAttributeView(caption: "mobile phone:",
                                          text: model.member(byId: memberId).mobilePhone)
                    }
                    if model.member(byId: memberId).workPhone != nil {
                        TextAttributeView(caption: "work phone:",
                                          text: model.member(byId: memberId).workPhone)
                    }
                }
                if model.member(byId: memberId).dateLastChanged != nil {
                    TextAttributeView(caption: "date last changed:", text: dateForDisplay(model.member(byId: memberId).dateLastChanged))
                }
                Section(header: Text("Transactions").font(.callout).italic()) {
                    TransactionsView(member: model.member(byId: memberId))
                }
                if model.member(byId: memberId).services.count > 0 {
                    Section(header: Text("Officer Service").font(.callout).italic()) {
                        ServicesView(member: model.member(byId: memberId))
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(model.member(byId: memberId).fullName())
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
