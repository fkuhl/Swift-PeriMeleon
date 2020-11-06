//
//  PhoneListView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistView: View {
    static let editAnimationDuration = 0.7
    
    @Binding var document: PeriMeleonDocument
    @State var members = [Member]()
    @State var showingResults = false

    var body: some View {
        VStack {
            if !showingResults {
                PhonelistEntryView(document: $document,
                                   members: $members,
                                   showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                PhonelistResultsView(document: $document,
                                     title: "\(members.count) entries",
                                     members: $members,
                                     showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

//struct PhoneListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhoneListView()
//    }
//}
