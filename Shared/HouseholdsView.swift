//
//  HouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct HouseholdsView: View {
    @Binding var document: PeriMeleonDocument
    @State private var allOrActive = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $allOrActive,
                       label: Text("What's in a name?"),
                       content: {
                        Text("All Households").tag(0)
                        Text("Active Households").tag(1)
                }).pickerStyle(SegmentedPickerStyle())
                List {
                    ForEach(allOrActive == 0 ? document.content.households : document.content.activeHouseholds, id: \.id) {
                        HouseholdRowView(document: $document, householdId: $0.id)
                    }
                }
            }
            .navigationBarTitle(allOrActive == 0 ? "All Households" : "Active Households")
        }
    }
}

//struct HouseholdView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdsView().environmentObject(HouseholdFetcher.mockedInstance)
//    }
//}
