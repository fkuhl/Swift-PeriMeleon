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
    var household: Household { get }
    func make() -> Member
}


class HouseholdAddressEditDelegate: AddressEditDelegate {
    var document: Binding<PeriMeleonDocument>
    
    init(document: Binding<PeriMeleonDocument>) {
        self.document = document
    }

    func store(address: Address, in household: Binding<Household>) {
        NSLog("HAED addr: \(address.address ?? "[none]") on \(household.wrappedValue.head.fullName())")
        household.wrappedValue.address = address
        document.wrappedValue.content.update(household: household.wrappedValue)
        //DataFetcher.sharedInstance.update(household: household.wrappedValue)
    }
}

struct HouseholdView: View {
    @Binding var document: PeriMeleonDocument
    @State var item: Household
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
    @Binding var household: Household
    var addressEditable = true
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate

    var body: some View {
        Form {
            Section {
                NavigationLink(destination: MemberInHouseholdView(
                                document: $document,
                    member: household.head,
                    household: $household,
                    relation: .head,
                    editable: true)) {
                        MemberLinkView(caption: "Head of household",
                                       name: household.head.fullName())
                }
                if household.spouse == nil {
                    Button(action: {
                        self.household.spouse = makeMember(from: self.spouseFactory)
                        document.content.update(household: self.household)
                    }) {
                        Text("Add spouse").font(.body)
                    }
                } else {
                    NavigationLink(destination: MemberInHouseholdView(
                                    document: $document,
                        member: household.spouse!,
                        household: $household,
                        relation: .spouse,
                        editable: true)) {
                            MemberLinkView(caption: "Spouse",
                                           name: household.spouse!.fullName())
                    }
                }
            }
            Section(header: Text("Dependents").font(.callout).italic()) {
                ForEach(household.others, id: \.id) {
                    OtherRowView(document: $document, other: $0, household: self.$household)
                }
                OtherAddView(otherFactory: self.otherFactory, household: $household)
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
        .navigationBarTitle(household.head.fullName())
    }
}

fileprivate struct AddressLinkView: View {
    @Binding var household: Household
    
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
    var other: Member
    @Binding var household: Household
    
    var body: some View {
        NavigationLink(destination: MemberInHouseholdView(
                        document: $document,
                        member: other,
                        household: $household,
                        relation: .other,
                        editable: true)) {
            MemberLinkView(captionWidth: defaultCaptionWidth,
                           caption: "",
                           name: other.fullName())
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
    var otherFactory: HouseholdMemberFactoryDelegate?
    @Binding var household: Household
    
    var body: some View {
        Button(action: {
            self.household.others.append(makeMember(from: self.otherFactory))
            NSLog("OAV hh \(self.household.head.fullName()) has \(self.household.others.count) others")
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
