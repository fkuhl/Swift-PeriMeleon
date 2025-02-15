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
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var showingActive = true
    @State private var households =
        SortedArray<NormalizedHousehold>(areInIncreasingOrder: compareHouseholds)
    @State private var filterText: String = ""

    var body: some View {
        VStack {
            VStack {
                Picker(selection: $showingActive,
                       label: Text("What's in a name?"),
                       content: {
                    Text("Active Households").tag(true)
                    Text("All Households").tag(false)
                })
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showingActive, initial: false) { _, _ in updateUI(filterText: filterText) }
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
                Text(showingActive ? "Active Households" : "All Households")
            })})
        .onAppear() { updateUI(filterText: "") }
        .onChange(of: document.changeCount, initial: false) { _, _ in updateUI(filterText: "") }
    }
    
    // MARK: - FilterUpdater

    func updateUI(filterText: String) {
        let candidates = showingActive
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
