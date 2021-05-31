//
//  AddressEditView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/1/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

protocol AddressEditDelegate {
    var document: Binding<PeriMeleonDocument> { get }

    func store(address: Address, in household: Binding<NormalizedHousehold>) -> Void
}

struct AddressEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var addressEditDelegate: AddressEditDelegate
    @Binding var household: NormalizedHousehold
    @State var address: Address

    var body: some View {
        VStack {
            Form {
                Section { //Section to group in sets of <= 10
                    EditOptionalTextView(caption: "address:", text: $address.address)
                    EditOptionalTextView(caption: "address2:", text: $address.address2)
                    EditOptionalTextView(caption: "city:", text: $address.city)
                    EditOptionalTextView(caption: "state:", text: $address.state)
                    EditOptionalTextView(caption: "postal code:", text: $address.postalCode)
                    EditOptionalTextView(caption: "country:", text: $address.country)
                    EditOptionalTextView(caption: "email:", text: $address.email)
                    EditOptionalTextView(caption: "home phone:", text: $address.homePhone)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            self.addressEditDelegate.store(address: self.address, in: self.$household)
        }) {
            Text("Save + Finish").font(.body)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("AEV cancel")
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel").font(.body)
        }
    }
}
