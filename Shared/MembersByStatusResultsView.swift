//
//  MembersByStatusResultsView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MembersByStatusResultsView: View {
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    
    var body: some View {
        VStack {
            Text(title).font(.title)
            HStack {
                Button(action: {
                    self.members = []
                    self.showingResults = false
                }) {
                    Text("Clear").font(.body)
                }.padding(20)
                Spacer()
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = makeClipboardEntry(members: self.members)
                }) {
                    Text("Copy to clipboard").font(.body)
                }.padding(20)
            }
            List {
                ForEach(members, id: \.id) {
                    ResultMemberView(member: $0)
                }
            }
        }
    }
}

fileprivate struct ResultMemberView: View {
    var member: Member
    
    var body: some View {
        Text(self.member.displayName()).font(.body)
    }
}

struct MembersByStatusResultsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let mocks = [mockMember1, mockMember2]
        return MembersByStatusResultsView(title: "This is The Title",
                                          members: .constant(mocks),
                                          showingResults: .constant(true))
    }
}

fileprivate func makeClipboardEntry(members: [Member]) -> String {
    var clip = "name,status"
    for member in members {
        clip += "\n\"\(member.displayName())\",\(member.status.rawValue)"
    }
    return clip
}
