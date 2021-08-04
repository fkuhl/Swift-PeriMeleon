//
//  SomeMembersView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/3/21.
//

import SwiftUI
import PMDataTypes

struct SomeMembersView: View, FilterUpdater {
    @EnvironmentObject var document: PeriMeleonDocument
    var allOrActive: AllOrActive
    @State private var members = SortedArray<Member>(areInIncreasingOrder: compareMembers)
    @State private var filterText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchField(filterText: $filterText,
                        uiUpdater: self,
                        sortMessage: "filter by name")
                
            List {
                ForEach(members) {
                    MemberRowView(memberId: $0.id)
                }
            }
        }
        .onAppear() {
            NSLog("SomeMembersView.onApp allOrActive \(allOrActive) \(members.count) members")
            updateUI(filterText: "")
        }

    }
    
    // MARK: - FilterUpdater

    func updateUI(filterText: String) {
        let candidates = allOrActive == .active
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
