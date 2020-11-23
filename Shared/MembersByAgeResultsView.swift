//
//  MembersByAgeResultsView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MembersByAgeResultsView: View {
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            Text(title).font(.title)
            HStack {
                Button(action: {
                    self.members = []
                    withAnimation(.easeInOut(duration: editAnimationDuration)) {
                        self.showingResults = false
                    }
                }) {
                    Text("Clear").font(.body)
                }.padding(20)
                Spacer()
                Button(action: {
//                    let pasteboard = UIPasteboard.general
//                    pasteboard.string = makeMembersByAgeResult(members: self.members)
                    queryResults.setCSV(results: makeMembersByAgeResult(members: self.members))
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").font(.body)
                }.padding(20)
            }
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Date of birth").font(.caption)
                    Text("Status").font(.caption)
                    Text("Sex").font(.caption)
                    ForEach(members, id: \.id) {
                        Text(memberName(member: $0)).font(.body)
                        Text(dob(member: $0)).font(.body)
                        Text($0.status.rawValue).font(.body)
                        Text($0.sex.rawValue).font(.body)
                    }
                }
            }.padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
//                .debugPrint("queryResults element has \((queryResults.toBeShared[0] as! NSString).length)")
        }
    }
}

private func memberName(member: Member) -> String {
    return member.displayName()
}

private func dob(member: Member) -> String {
    if let dob = member.dateOfBirth {
        return dateFormatter.string(from: dob)
    } else { return "" }
}

struct MembersByAgeResultsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let mocks = [mockMember1, mockMember2]
        return MembersByAgeResultsView(title: "This is The Title",
                                          members: .constant(mocks),
                                          showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}

fileprivate func makeMembersByAgeResult(members: [Member]) -> String {
    var csvReturn = "name,dob,status,sex"
    let strings = members.map { member in
        "\"\(memberName(member: member))\",\(dob(member: member)),\(member.status)),\"\(member.sex)\""
    }
    csvReturn = strings.reduce(csvReturn) { thusFar, newString in
        "\(thusFar)\n\(newString)"
    }
    return csvReturn
}
