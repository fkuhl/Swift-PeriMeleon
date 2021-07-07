//
//  ChooseHouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct ChooseHouseholdView: View {
    @ObservedObject var model: Model = .shared
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var householdId: ID
    
    var body: some View {
        NavigationLink(destination: ChooseHouseholdListView(householdId: $householdId)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(model.nameOf(household: householdId)).font(.body)
            }
        }
    }
}


struct ChooseHouseholdListView: View {
    @ObservedObject var model: Model = .shared
    @State private var allOrActive = 0
    @Binding var householdId: ID
    
    var body: some View {
        VStack {
            Picker(selection: $allOrActive,
                   label: Text("What's in a name?"),
                   content: {
                    Text("All Households").tag(0)
                    Text("Active Households").tag(1)
            }).pickerStyle(SegmentedPickerStyle())
            List {
                ForEach(allOrActive == 0 ? model.households
                            : model.activeHouseholds, id: \.id) {
                    ChooseHouseholdRowView(household: $0,
                                           chosenId: $householdId)
                }
            }
        }
    }
}

struct ChooseHouseholdRowView: View {
    @ObservedObject var model: Model = .shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var household: NormalizedHousehold
    @Binding var chosenId: ID
    
    var body: some View {
        HStack {
            Button(action: {
                self.chosenId = self.household.id
                self.presentationMode.wrappedValue.dismiss()
            } ) {
                Text(model.nameOf(household: household)).font(.body)
            }
        }
    }
}
