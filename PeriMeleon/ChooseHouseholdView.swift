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
    @EnvironmentObject var document: PeriMeleonDocument
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var householdId: ID
    
    var body: some View {
        NavigationLink(destination: ChooseHouseholdListView(householdId: $householdId).environmentObject(document)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(document.nameOf(household: householdId)).font(.body)
            }
        }
    }
}


struct ChooseHouseholdListView: View, FilterUpdater {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var allOrActive = 0
    @Binding var householdId: ID
    @State private var households =
        SortedArray<NormalizedHousehold>(areInIncreasingOrder: compareHouseholds)
    @State private var filterText: String = ""

    var body: some View {
        VStack {
            VStack {
                Picker(selection: $allOrActive,
                       label: Text("What's in a name?"),
                       content: {
                        Text("Active Households").tag(0)
                        Text("All Households").tag(1)
                       }).pickerStyle(SegmentedPickerStyle())
                    .onChange(of: allOrActive, initial: false) { _, _ in updateUI(filterText: filterText) }
                SearchField(filterText: $filterText,
                            uiUpdater: self,
                            sortMessage: "filter by name")
            }
            .padding()
            List {
                ForEach(households) {
                    ChooseHouseholdRowView(household: $0,
                                           chosenId: $householdId)
                }
            }
        }
        .onAppear() { updateUI(filterText: "")
        }
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

struct ChooseHouseholdRowView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var household: NormalizedHousehold
    @Binding var chosenId: ID
    
    var body: some View {
        HStack {
            Button(action: {
                self.chosenId = self.household.id
                self.presentationMode.wrappedValue.dismiss()
            } ) {
                Text(document.nameOf(household: household)).font(.body)
            }
        }
    }
}
