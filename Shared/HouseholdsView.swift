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
                        Text("Active Households").tag(0)
                        Text("All Households").tag(1)
                }).pickerStyle(SegmentedPickerStyle())
                List {
                    ForEach(allOrActive == 0
                                ? document.activeHouseholds
                                : document.households, id: \.id) {
                        HouseholdRowView(document: $document, householdId: $0.id)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text(allOrActive == 0 ? "Active Households" : "All Households")
                        })})
        }
    }
}
