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
    /**
     Passing this changeCount to subordinate views seems to make this view update properly
     if they change data and bump up the changeCount.
     I don't understand why just changing the document doesn't have this effect.
     */
    @State private var changeCount = 0

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
                    OtherRowView(document: $document,
                                 memberId: $0,
                                 changeCount: $changeCount)
                }
                OtherAddView(document: $document,
                             otherFactory: otherFactory,
                             householdId: householdId,
                             changeCount: $changeCount)
            }
            Section(header: Text("Address").font(.callout).italic()) {
                if nugatory(document.household(byId: householdId).address) {
                    NavigationLink(destination: newAddressDestination) {
                        Text("Add address").font(.body)
                    }
                } else {
                    NavigationLink(destination: addressDestination) {
                        AddressLinkView(document: $document, householdId: householdId)
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
            changeCount: $changeCount)
    }
    
    private var headLink: some View {
        MemberLinkView(caption: "Head of household",
                       name: document.nameOf(household: document.household(byId: householdId)))
    }
    
    private var spouseDestination: some View {
        MemberView(document: $document,
                   memberId: document.household(byId: householdId).spouse!,
                   changeCount: $changeCount)
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
        changeCount += 1
    }
    
    private var newAddressDestination: some View {
        AddressEditView(document: $document,
                        householdId: householdId,
                        address: Address(),
                        changeCount: $changeCount)
    }
    
    private var addressDestination: some View {
        AddressEditView(document: $document,
                        householdId: householdId,
                        address: document.household(byId: householdId).address!,
                        changeCount: $changeCount)
    }
}

class PreviewHouseholdMemberFactoryDelegate: HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument>
    var householdId: ID
    
    init(document: Binding<PeriMeleonDocument>, householdId: ID) {
        self.document = document
        self.householdId = householdId
    }
    
    func make() -> Member {
        Member()
    }
    
    
}

/**
 For PreviewProviderModifier, see:
https://www.avanderlee.com/swiftui/previews-different-states/
*/
struct HouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdView(document: mockDocument,
                      householdId: mockHousehold.id,
                      spouseFactory: PreviewHouseholdMemberFactoryDelegate(
                        document: mockDocument,
                        householdId: mockHousehold.id),
                      otherFactory: PreviewHouseholdMemberFactoryDelegate(
                        document: mockDocument,
                        householdId: mockHousehold.id))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}

//MARK: - Address

fileprivate struct AddressLinkView: View {
    @Binding var document: PeriMeleonDocument
    @State var householdId: ID
    
    var body: some View {
        Text(document.household(byId: householdId).address?.addressForDisplay() ?? "[none]").font(.body)
    }
}

//MARK: - Members

protocol HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument> { get }
    var householdId: ID { get }
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
    @Binding var changeCount: Int
    
    var body: some View {
        NavigationLink(destination: MemberView(
                        document: $document,
                        memberId: memberId,
                        changeCount: $changeCount)) {
            MemberLinkView(captionWidth: defaultCaptionWidth,
                           caption: "",
                           name: document.nameOf(member: memberId))
        }//.debugPrint("ORV for \(document.nameOf(member: memberId))")
    }
}

fileprivate struct OtherAddView: View {
    @Binding var document: PeriMeleonDocument
    var otherFactory: HouseholdMemberFactoryDelegate
    var householdId: ID
    @Binding var changeCount: Int
    
    var body: some View {
        Button(action: {
            let newOther = otherFactory.make()
            document.add(member: newOther)
            var household = document.household(byId: householdId)
            // This looks roundabout. But making a new array and adding
            // it back to the household makes it look new to SWiftUI,
            // causing a view update.
            // --except it doesn't; hence addition of changeCount.
            var others = household.others
            others.append(newOther.id)
            household.others = others
            document.update(household: household)
            changeCount += 1
            NSLog("OAV hh \(document.nameOf(household: household.id)) has \(household.others.count) others")
        }) {
            Image(systemName: "plus").font(.body)
        }
    }
}
