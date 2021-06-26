//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI


struct MembersView: View {
    @Binding var document: PeriMeleonDocument
    @State private var allOrActive = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $allOrActive,
                       label: Text("What's in a name?"),
                       content: {
                        Text("Active Members").tag(0)
                        Text("All Members").tag(1)
                       }).pickerStyle(SegmentedPickerStyle())
                List {
                    ForEach(allOrActive == 0
                                ? document.activeMembers
                                : document.members) {
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
    }
}



struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
        MembersView(document: mockDocument)
    }
}
