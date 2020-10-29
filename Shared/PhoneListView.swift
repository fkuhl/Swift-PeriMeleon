//
//  PhoneListView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhoneListView: View {
    @Binding var document: PeriMeleonDocument
    @State var includeResident = true
    @State var includeNonResident = false
    @State var includeMen = true
    @State var includeWomen = false
    @State var minimumAge = 14
    @State var members = [Member]()
    @State var showingResults = false

    var body: some View {
        VStack {
            if !showingResults {
                PhonelistEntryView(document: $document,
                                   includeResident: $includeResident,
                                   includeNonResident: $includeNonResident,
                                   includeMen: $includeMen,
                                   includeWomen: $includeWomen,
                                   minimumAge: $minimumAge,
                                         members: $members,
                                         showingResults: $showingResults)
            } else {
                PhonelistResultsView(title: "\(members.count) entries",
                                           members: $members,
                                           showingResults: $showingResults)
            }
        }
    }
}

//struct PhoneListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhoneListView()
//    }
//}
