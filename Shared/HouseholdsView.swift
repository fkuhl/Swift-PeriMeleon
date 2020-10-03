//
//  HouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct HouseholdsView: View {
    @ObservedObject var dataFetcher = DataFetcher.sharedInstance
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
                    ForEach(allOrActive == 0 ? dataFetcher.sortedHouseholds : dataFetcher.activeHouseholds, id: \.id) {
                        HouseholdRowView(item: $0)
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
