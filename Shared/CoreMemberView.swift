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
    var member: Member
    var memberEditDelegate: MemberEditDelegate
    var memberCancelDelegate: MemberCancelDelegate
    var editable = true
    let closingAction: (_ member: Member, _ delegate: MemberEditDelegate) -> Void
    
    var body: some View {
        VStack {
            if editable {
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: MemberEditView(
                            member: member,
                            memberEditDelegate: memberEditDelegate,
                            memberCancelDelegate: memberCancelDelegate,
                            closingAction: self.closingAction,
                            navigationBarTitle: member.fullName()))  {
                                Text("Edit").font(.body)
                    }
                }.padding()
            }
            List {
                Section {
                    TextAttributeView(caption: "family name:", text: member.familyName)
                    TextAttributeView(caption: "given name:", text: member.givenName)
                    if member.middleName != nil {
                        TextAttributeView(caption: "middle name:", text: member.middleName)
                    }
                    if member.previousFamilyName != nil {
                        TextAttributeView(caption: "prev fam name:", text: member.previousFamilyName)
                    }
                    if member.nameSuffix != nil {
                        TextAttributeView(caption: "suffix:", text: member.nameSuffix)
                    }
                    if member.title != nil {
                        TextAttributeView(caption: "title:", text: member.title)
                    }
                    if member.nickname != nil {
                        TextAttributeView(caption: "nickname:", text: member.nickname)
                    }
                    TextAttributeView(caption: "sex:", text: member.sex.rawValue)
                    TextAttributeView(caption: "status:", text: member.status.rawValue)
                }
                Section {
                    TextAttributeView(caption: "resident:", text: member.resident ? "yes" : "no")
                    TextAttributeView(caption: "ex-directory:", text: member.exDirectory ? "yes" : "no")
                    if member.dateOfBirth != nil {
                        TextAttributeView(caption: "date of birth:", text: dateForDisplay(member.dateOfBirth!))
                    }
                    if member.placeOfBirth != nil {
                        TextAttributeView(caption: "place of birth:", text: member.placeOfBirth!)
                    }
                    if member.baptism != nil {
                        TextAttributeView(caption: "baptism:", text: member.baptism)
                    }
                    TextAttributeView(caption: "household:", text: householdName(for: member))
                    TextAttributeView(caption: "martial status:", text: member.maritalStatus.rawValue)
                    if member.spouse != nil {
                        TextAttributeView(caption: "spouse:", text: member.spouse)
                    }
                    if member.dateOfMarriage != nil {
                        TextAttributeView(caption: "date of marriage:", text: dateForDisplay(member.dateOfMarriage))
                    }
                    if member.divorce != nil {
                        TextAttributeView(caption: "divorce:", text: member.divorce)
                    }
                }
                Section {
                    if member.father != nil {
                        TextAttributeView(caption: "father:", text: memberName(id: member.father!))
                    }
                    if member.mother != nil {
                        TextAttributeView(caption: "mother:", text: memberName(id: member.mother!))
                    }
                    if member.eMail != nil {
                        TextAttributeView(caption: "email:", text: member.eMail)
                    }
                    if member.workEmail != nil {
                        TextAttributeView(caption: "work email:", text: member.workEmail)
                    }
                    if member.mobilePhone != nil {
                        TextAttributeView(caption: "mobile phone:", text: member.mobilePhone)
                    }
                    if member.workPhone != nil {
                        TextAttributeView(caption: "work phone:", text: member.workPhone)
                    }
                }
                if member.dateLastChanged != nil {
                    TextAttributeView(caption: "date last changed:", text: dateForDisplay(member.dateLastChanged))
                }
                Section(header: Text("Transactions").font(.callout).italic()) {
                    TransactionsView(member: member)
                }
                if member.services.count > 0 {
                    Section(header: Text("Officer Service").font(.callout).italic()) {
                        ServicesView(member: member)
                    }
                }
            }.listStyle(GroupedListStyle())
        }.navigationBarTitle("\(member.fullName())")
    }
}

fileprivate func householdName(for member: Member) -> String {
    let household = DataFetcher.sharedInstance.householdIndex[member.household]
    return household == nil ? "[none]" : household!.head.fullName()
}

fileprivate func memberName(id: Id) -> String {
    let memberRecord = DataFetcher.sharedInstance.memberIndex[id]
    return memberRecord == nil ? "[none]" : memberRecord!.member.fullName()
}
var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
}


//struct CoreMemberView_Previews: PreviewProvider {
//    static var previews: some View {
//        CoreMemberView()
//    }
//}
