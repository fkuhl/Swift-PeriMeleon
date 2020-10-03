//
//  AddressView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/1/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

//struct AddressView: View {
//    @Binding var address: Address
//    var addressEditDelegate: AddressEditDelegate
//    var editable = true
//    
//    var body: some View {
//        VStack {
//            if editable {
//                HStack {
//                    Spacer()
//                    NavigationLink(
//                        destination: AddressEditView(
//                            addressEditDelegate: addressEditDelegate,
//                            address: address)) {
//                                Text("Edit").font(.body)
//                    }
//                }.padding()
//            }
//            List {
//                Section {
//                    TextAttributeView(caption: "address:", text: address.address)
//                    TextAttributeView(caption: "address2:", text: address.address2)
//                    TextAttributeView(caption: "city:", text: address.city)
//                    TextAttributeView(caption: "state:", text: address.state)
//                    TextAttributeView(caption: "postal code:", text: address.postalCode)
//                    TextAttributeView(caption: "country:", text: address.country)
//                    TextAttributeView(caption: "email:", text: address.email)
//                    TextAttributeView(caption: "home phone:", text: address.homePhone)
//                }
//            }.listStyle(GroupedListStyle())
//        }
//    }
//}

//struct AddressView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressView()
//    }
//}
