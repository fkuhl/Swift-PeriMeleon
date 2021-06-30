//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes


struct MembersView: View, FilterUpdater {
    @Binding var document: PeriMeleonDocument
    @State private var allOrActive = 0
    @State private var members: [Member] = []
    @State private var filterText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker(selection: $allOrActive,
                           label: Text("What's in a name?"),
                           content: {
                            Text("Active Members").tag(0)
                            Text("All Members").tag(1)
                           }).pickerStyle(SegmentedPickerStyle())
                        .onChange(of: allOrActive) { _ in updateUI(filterText: filterText) }
                    SearchField(filterText: $filterText,
                                uiUpdater: self,
                                sortMessage: "filter by name")
                }.padding()
                List {
                    ForEach(members) {
                        MemberRowView(document: $document, memberId: $0.id)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text(allOrActive == 0 ? "Active Members" : "All Members")
                        })})
        }
        .onAppear() { updateUI(filterText: "") }
    }
    
    // MARK: - FilterUpdater

    func updateUI(filterText: String) {
        let candidates = allOrActive == 0
            ? document.activeMembers
            : document.members
        if filterText.isEmpty {
            members = candidates
            return
        }
        members = candidates.filter { member in
            document.nameOf(member: member.id).localizedCaseInsensitiveContains(filterText)
        }
    }
}



struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
        MembersView(document: mockDocument)
            .padding()
            .background(Color(.systemBackground))
            .previewLayout(.fixed(width: 1024, height: 768))
    }
}
