//
//  ChooseMemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct ChooseMemberView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    @Binding var memberId: ID
    var filter: MemberFilter = { member in true } //default includes everything
    
    var body: some View {
        NavigationLink(destination: ChooseMemberListView(memberId: $memberId,
                                                         filter: filter)
                        .environmentObject(document)) {
            HStack(alignment: .lastTextBaseline) {
                Text(caption)
                    .frame(width: captionWidth, alignment: .trailing)
                    .font(.caption)
                Spacer()
                Text(document.nameOf(member: memberId)).font(.body)
            }
        }
    }
}


struct ChooseMemberListView: View, FilterUpdater {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var allOrActive = 0
    @Binding var memberId: ID
    @State private var members = SortedArray<Member>(areInIncreasingOrder: compareMembers)
    @State private var filterText: String = ""
    var filter: MemberFilter

    var body: some View {
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
            }
            .padding()
            List {
                ForEach(members) {
                    ChooseMemberRowView(member: $0,
                                           chosenId: $memberId)
                }
            }
        }
        .onAppear() { updateUI(filterText: "")
        }
    }
    
    // MARK: - FilterUpdater

    func updateUI(filterText: String) {
        let candidates = allOrActive == 0
            ? document.activeMembers
            : document.members
        if filterText.isEmpty {
            members = candidates.filter(filter)
            return
        }
        members = candidates.filter { member in
            document.nameOf(member: member.id).localizedCaseInsensitiveContains(filterText)
        }
        members = members.filter(filter)
    }
}

struct ChooseMemberRowView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var member: Member
    @Binding var chosenId: ID
    
    var body: some View {
        HStack {
            Button(action: {
                self.chosenId = self.member.id
                self.presentationMode.wrappedValue.dismiss()
            } ) {
                Text(document.nameOf(member: member.id)).font(.body)
            }
        }
    }
}
