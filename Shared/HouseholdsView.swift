//
//  HouseholdsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI
import PMDataTypes

struct HouseholdsView: View {
    @Binding var households: [Household]
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
                    ForEach(households.indices) {
                        index in
                        HouseholdRowView(item: $households[index])
                    }
                }
            }
            .navigationBarTitle(allOrActive == 0 ? "All Households" : "Active Households")
        }
    }
}

//struct HouseholdsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdsView()
//    }
//}
