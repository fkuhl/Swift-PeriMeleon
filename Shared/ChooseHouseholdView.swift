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
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var householdId: Id
    
    var body: some View {
//        let localHouseholdId = Binding<Id> (
//            get: {
//                NSLog("CHV get \(nameOfHousehold(self.householdId))")
//                return self.householdId
//            }, set: {
//                NSLog("CHV set** \(nameOfHousehold($0))")
//                self.householdId = $0
//            }
//        )
        
        NavigationLink(destination: ChooseHouseholdListView(householdId: $householdId)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(nameOfHousehold(householdId)).font(.body)
            }
        }
    }
}


struct ChooseHouseholdListView: View {
    @ObservedObject var dataFetcher = DataFetcher.sharedInstance
    @State private var allOrActive = 0
    @Binding var householdId: Id
    
    var body: some View {
        VStack {
            Picker(selection: $allOrActive,
                   label: Text("What's in a name?"),
                   content: {
                    Text("All Households").tag(0)
                    Text("Active Households").tag(1)
            }).pickerStyle(SegmentedPickerStyle())
            List {
                ForEach(allOrActive == 0 ? dataFetcher.sortedHouseholds : dataFetcher.activeHouseholds, id: \.id) {
                    ChooseHouseholdRowView(household: $0, chosenId: self.$householdId)
                }
            }
        }
    }
}

struct ChooseHouseholdRowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var household: Household
    @Binding var chosenId: Id
    
    var body: some View {
        HStack {
            Button(action: {
                self.chosenId = self.household.id
                self.presentationMode.wrappedValue.dismiss()
            } ) {
                Text(household.head.fullName()).font(.body)
            }
        }
    }
}

//struct ChooseHouseholdView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChooseHouseholdView()
//    }
//}
