//
//  HouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/14/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes


protocol HouseholdMemberFactoryDelegate {
    var document: Binding<PeriMeleonDocument> { get }
    var household: NormalizedHousehold { get }
    func make() -> Member
}


class HouseholdAddressEditDelegate: AddressEditDelegate {
    var document: Binding<PeriMeleonDocument>
    
    init(document: Binding<PeriMeleonDocument>) {
        self.document = document
    }

    func store(address: Address, in household: Binding<NormalizedHousehold>) {
        NSLog("HAED addr: \(address.address ?? "[none]") on \(document.wrappedValue.content.nameOf(household: household.wrappedValue))")
        household.wrappedValue.address = address
        document.wrappedValue.content.update(household: household.wrappedValue)
    }
}

struct HouseholdView: View {
    @Binding var document: PeriMeleonDocument
    @State var item: NormalizedHousehold
    var addressEditable = true
    var replaceButtons = false
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate
    
    var body: some View {
        VStack {
            if replaceButtons {
                UnadornedHouseholdView(document: $document,
                                       household: $item,
                                       addressEditable: addressEditable,
                                       spouseFactory: self.spouseFactory,
                                       otherFactory: self.otherFactory)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: EmptyView(),
                                    trailing: EmptyView())
            } else {
                UnadornedHouseholdView(document: $document,
                                       household: $item,
                                       addressEditable: addressEditable,
                                       spouseFactory: self.spouseFactory,
                                       otherFactory: self.otherFactory)
            }
        }
    }
}

fileprivate struct UnadornedHouseholdView: View {
    @Binding var document: PeriMeleonDocument
    @Binding var household: NormalizedHousehold
    var addressEditable = true
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate

    var body: some View {
        Form {
            Section {
                NavigationLink(destination: MemberView(
                                document: $document,
                                memberId: household.head,
                                editable: true)) {
                    MemberLinkView(caption: "Head of household",
                                   name: $document.wrappedValue.content.nameOf(household: household))
                }
                if household.spouse == nil {
                    Button(action: {
                        let newSpouse = makeMember(from: self.spouseFactory)
                        document.content.add(member: newSpouse)
                        self.household.spouse = newSpouse.id
                        document.content.update(household: self.household)
                    }) {
                        Text("Add spouse").font(.body)
                    }
                } else {
                    NavigationLink(destination: MemberView(
                                    document: $document,
                                    memberId: household.spouse!,
                                    editable: true)) {
                        MemberLinkView(caption: "Spouse",
                                       name: $document.wrappedValue.content.nameOf(member: household.spouse!))
                    }
                }
            }
            Section(header: Text("Dependents").font(.callout).italic()) {
                ForEach(household.others, id: \.self) {
                    OtherRowView(document: $document,
                                 otherId: $0,
                                 household: $household)
                }
                OtherAddView(document: $document,
                             otherFactory: otherFactory,
                             household: $household)
            }
            Section(header: Text("Address").font(.callout).italic()) {
                if nugatory(household.address) {
                    NavigationLink(destination: AddressEditView(
                                    addressEditDelegate: HouseholdAddressEditDelegate(document: $document),
                        household: $household,
                        address: Address())) {
                            Text("Add address").font(.body)
                    }
                } else {
                    NavigationLink(destination: AddressEditView(
                        addressEditDelegate: HouseholdAddressEditDelegate(document: $document),
                        household: $household,
                        address: household.address!)) {
                            AddressLinkView(household: $household)
                    }
                }
            }
        }
        .navigationBarTitle($document.wrappedValue.content.nameOf(household: household))
    }
}

fileprivate struct AddressLinkView: View {
    @Binding var household: NormalizedHousehold
    
    var body: some View {
        Text(self.household.address?.addressForDisplay() ?? "[none]").font(.body)
    }
}

fileprivate func makeMember(from factory: HouseholdMemberFactoryDelegate?) -> Member {
    if let factory = factory {
        return factory.make()
    }
    else { return Member() }
}

fileprivate struct OtherRowView: View {
    @Binding var document: PeriMeleonDocument
    var otherId: Id
    @Binding var household: NormalizedHousehold
    
    var body: some View {
        NavigationLink(destination: MemberView(
                        document: $document,
                        memberId: otherId,
                        editable: true)) {
            MemberLinkView(captionWidth: defaultCaptionWidth,
                           caption: "",
                           name: document.content.nameOf(member: otherId))
        }
    }
}

struct MemberLinkView: View {
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

struct OtherAddView: View {
    @Binding var document: PeriMeleonDocument
    var otherFactory: HouseholdMemberFactoryDelegate?
    @Binding var household: NormalizedHousehold
    
    var body: some View {
        Button(action: {
            let newOther = makeMember(from: self.otherFactory)
            document.content.add(member: newOther)
            household.others.append(newOther.id)
            NSLog("OAV hh \(document.content.nameOf(household: household.id)) has \(household.others.count) others")
        }) {
            Image(systemName: "plus").font(.body)
        }
    }
}

//struct HouseholdView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdView()
//    }
//}
