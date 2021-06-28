//
//  HouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/14/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes


struct HouseholdView: View {
    @Binding var document: PeriMeleonDocument
    var householdId: ID
    var addressEditable = true
    var replaceButtons = false
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate

    var body: some View {
        Form {
            Section {
                NavigationLink(destination: headDestination) { headLink }
                if document.household(byId: householdId).spouse == nil {
                    Button(action: addSpouse) { Text("Add spouse").font(.body) }
                } else {
                    NavigationLink(destination: spouseDestination) { spouseLink }
                }
            }
            Section(header: Text("Dependents").font(.callout).italic()) {
                ForEach(document.household(byId: householdId).others, id: \.self) {
                    OtherRowView(document: $document, memberId: $0)
                }
                OtherAddView(document: $document,
                             otherFactory: otherFactory,
                             householdId: householdId)
            }
            Section(header: Text("Address").font(.callout).italic()) {
                if nugatory(document.household(byId: householdId).address) {
                    NavigationLink(destination: newAddressDestination) {
                        Text("Add address").font(.body)
                    }
                } else {
                    NavigationLink(destination: addressDestination) {
                        AddressLinkView(household: document.household(byId: householdId))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        Text(document.nameOf(household: document.household(byId: householdId)))
                    })})
    }
    
    private var headDestination: some View {
        MemberView(
            document: $document,
            memberId: document.household(byId: householdId).head,
            editable: true)
    }
    
    private var headLink: some View {
        MemberLinkView(caption: "Head of household",
                       name: document.nameOf(household: document.household(byId: householdId)))
    }
    
    private var spouseDestination: some View {
        MemberView(document: $document,
                   memberId: document.household(byId: householdId).spouse!,
                   editable: true)
    }
    
    private var spouseLink: some View {
        MemberLinkView(caption: "Spouse",
                       name: document.nameOf(member: document.household(byId: householdId).spouse!))
    }

    private func addSpouse() {
        let newSpouse = spouseFactory.make()
        document.add(member: newSpouse)
        var changingHousehold = document.household(byId: householdId)
        changingHousehold.spouse = newSpouse.id
        document.update(household: changingHousehold)
    }
    
    private var newAddressDestination: some View {
        AddressEditView(document: $document,
                        householdId: householdId,
                        address: Address())
    }
    
    private var addressDestination: some View {
        AddressEditView(document: $document,
                        householdId: householdId,
                        address: document.household(byId: householdId).address!)
    }
}

class PreviewHouseholdMemberFactoryDelegate: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    var household: NormalizedHousehold
    
    init(document: Binding<PeriMeleonDocument>, household: NormalizedHousehold) {
        self.document = document
        self.household = household
    }
    
    func make() -> Member {
        Member()
    }
    
    
}

/**
 For PreviewProviderModifier, see:
https://www.avanderlee.com/swiftui/previews-different-states/?utm_source=SwiftLee+-+Subscribers&utm_campaign=62bdcb91d7-EMAIL_CAMPAIGN_2020_03_02_08_48_COPY_01&utm_medium=email&utm_term=0_e154f6bfee-62bdcb91d7-367632929
*/
struct HouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdView(document: mockDocument,
                      householdId: mockHousehold.id,
                      spouseFactory: PreviewHouseholdMemberFactoryDelegate(document: mockDocument,
                                                                           household: mockHousehold),
                      otherFactory: PreviewHouseholdMemberFactoryDelegate(document: mockDocument,
                                                                          household: mockHousehold))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}

//MARK: - Address

fileprivate struct AddressLinkView: View {
    var household: NormalizedHousehold
    
    var body: some View {
        Text(household.address?.addressForDisplay() ?? "[none]").font(.body)
    }
}

//MARK: - Members

protocol HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument> { get }
    var household: NormalizedHousehold { get }
    func make() -> Member
}

fileprivate struct MemberLinkView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    var name: String

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Spacer()
            Text(name).frame(alignment: .leading).font(.body)
        }
    }
}

fileprivate struct OtherRowView: View {
    @Binding var document: PeriMeleonDocument
    var memberId: ID
    
    var body: some View {
        NavigationLink(destination: MemberView(
                        document: $document,
                        memberId: memberId,
                        editable: true)) {
            MemberLinkView(captionWidth: defaultCaptionWidth,
                           caption: "",
                           name: document.nameOf(member: memberId))
        }
    }
}

fileprivate struct OtherAddView: View {
    @Binding var document: PeriMeleonDocument
    var otherFactory: HouseholdMemberFactoryDelegate
    var householdId: ID
    
    var body: some View {
        Button(action: {
            let newOther = otherFactory.make()
            document.add(member: newOther)
            var household = document.household(byId: householdId)
            // This looks roundabout. But making a new array and adding
            // it back to the household makes it look new to SWiftUI,
            // causing a view update.
            var others = household.others
            others.append(newOther.id)
            household.others = others
            document.update(household: household)
            NSLog("OAV hh \(document.nameOf(household: household.id)) has \(household.others.count) others")
        }) {
            Image(systemName: "plus").font(.body)
        }
    }
}
