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

    func store(address: Address, in household: Binding<Household>) {
        NSLog("HAED addr: \(address.address ?? "[none]") on \(household.wrappedValue.head.fullName())")
        household.wrappedValue.address = address
        DataFetcher.sharedInstance.update(household: household.wrappedValue)
    }
}

struct HouseholdView: View {
    @State var item: Household
    var addressEditable = true
    var replaceButtons = false
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate
    
    var body: some View {
        VStack {
            if replaceButtons {
                UnadornedHouseholdView(item: $item,
                                       addressEditable: addressEditable,
                                       spouseFactory: self.spouseFactory,
                                       otherFactory: self.otherFactory)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: EmptyView(),
                                    trailing: EmptyView())
            } else {
                UnadornedHouseholdView(item: $item,
                                       addressEditable: addressEditable,
                                       spouseFactory: self.spouseFactory,
                                       otherFactory: self.otherFactory)
            }
        }
    }
}

fileprivate struct UnadornedHouseholdView: View {
    @Binding var item: Household
    var addressEditable = true
    var spouseFactory: HouseholdMemberFactoryDelegate
    var otherFactory: HouseholdMemberFactoryDelegate

    var body: some View {
        Form {
            Section {
                NavigationLink(destination: MemberInHouseholdView(
                    member: item.head,
                    household: $item,
                    relation: .head,
                    editable: true)) {
                        MemberLinkView(caption: "Head of household",
                                       name: item.head.fullName())
                }
                if item.spouse == nil {
                    Button(action: {
                        self.item.spouse = makeMember(from: self.spouseFactory)
                        DataFetcher.sharedInstance.update(household: self.item)
                    }) {
                        Text("Add spouse").font(.body)
                    }
                } else {
                    NavigationLink(destination: MemberInHouseholdView(
                        member: item.spouse!,
                        household: $item,
                        relation: .spouse,
                        editable: true)) {
                            MemberLinkView(caption: "Spouse",
                                           name: item.spouse!.fullName())
                    }
                }
            }
            Section(header: Text("Dependents").font(.callout).italic()) {
                ForEach(item.others, id: \.id) {
                    OtherRowView(other: $0, household: self.$item)
                }
                OtherAddView(otherFactory: self.otherFactory, household: $item)
            }
            Section(header: Text("Address").font(.callout).italic()) {
                if nugatory(item.address) {
                    NavigationLink(destination: AddressEditView(
                        addressEditDelegate: HouseholdAddressEditDelegate(),
                        household: $item,
                        address: Address())) {
                            Text("Add address").font(.body)
                    }
                } else {
                    NavigationLink(destination: AddressEditView(
                        addressEditDelegate: HouseholdAddressEditDelegate(),
                        household: $item,
                        address: item.address!)) {
                            AddressLinkView(household: $item)
                    }
                }
            }
        }
        .navigationBarTitle(item.head.fullName())
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
    var other: Member
    @Binding var household: Household
    
    var body: some View {
        NavigationLink(destination: MemberInHouseholdView(
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
