//
//  PhoneListView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistView: View {
    @State var members = [Member]()
    @State var showingResults = false

    var body: some View {
        VStack {
            if !showingResults {
                PhonelistEntryView(members: $members,
                                   showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                PhonelistResultsView(title: "\(members.count) entries",
                                     members: $members,
                                     showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Export Phone List")
            }
        }
    }
}

struct PhonelistView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistView()
    }
}
