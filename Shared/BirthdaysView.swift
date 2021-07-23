//
//  BirthdaysView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/17/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct BirthdaysView: View {
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Hun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    @State var selectedMonth = 0
    @State var members = [Member]()
    @State var showingResults = false
    
    var body: some View {
        VStack {
            if !showingResults {
                BirthdaysEntryView(selectedMonth: $selectedMonth,
                                   members: $members,
                                   showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                BirthdaysResultsView(title: "\(members.count) Member\(members.count > 1 ? "s" : "") With Birthdays in \(months[selectedMonth])",
                                     members: $members,
                                     showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Birthdays")
            }
        }
    }
}

struct Birthdays_Previews: PreviewProvider {
    static var previews: some View {
        BirthdaysView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
            .environmentObject(mockDocument)
    }
}
