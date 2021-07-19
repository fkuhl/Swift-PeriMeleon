//
//  HouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes


struct HouseholdsView: View, FilterUpdater {
    @ObservedObject var document = PeriMeleonDocument.shared
    @State private var allOrActive = 0
    @State private var households: [NormalizedHousehold] = []
    @State private var filterText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker(selection: $allOrActive,
                           label: Text("What's in a name?"),
                           content: {
                            Text("Active Households").tag(0)
                            Text("All Households").tag(1)
                           })
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: allOrActive) { _ in updateUI(filterText: filterText) }
                    SearchField(filterText: $filterText,
                                uiUpdater: self,
                                sortMessage: "filter by name")
                }.padding()
                List {
                    ForEach(households) {
                        HouseholdRowView(householdId: $0.id)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text(allOrActive == 0 ? "Active Households" : "All Households")
                        })})
        }
        .onAppear() { updateUI(filterText: "") }
    }
    
    // MARK: - FilterUpdater

    func updateUI(filterText: String) {
        let candidates = allOrActive == 0
            ? document.activeHouseholds
            : document.households
        if filterText.isEmpty {
            households = candidates
            return
        }
        households = candidates.filter { household in
            document.nameOf(household: household.id).localizedCaseInsensitiveContains(filterText)
        }
    }
}
