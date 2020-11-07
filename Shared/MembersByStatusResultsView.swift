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
//                    pasteboard.string = makeMembersByStatusResult(members: self.members)
                    queryResults.setCSV(results: makeMembersByStatusResult(members: self.members))
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").font(.body)
                }.padding(20)
            }
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Date joined").font(.caption)
                    Text("Recep type").font(.caption)
                    Text("From church").font(.caption)
                    ForEach(members, id: \.id) {
                        Text(memberName(member: $0)).font(.body)
                        Text(dateJoined(member: $0)).font(.body)
                        Text(receptionType(member: $0)).font(.body)
                        Text(churchFrom(member: $0)).font(.body)
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

private func dateJoined(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    let date = member.transactions[0].date
    if date == nil { return "" }
    return dateFormatter.string(from: date!)
}

private func receptionType(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions[0].type.rawValue
}

private func churchFrom(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions[0].church ?? ""
}

struct MembersByStatusResultsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let mocks = [mockMember1, mockMember2]
        return MembersByStatusResultsView(title: "This is The Title",
                                          members: .constant(mocks),
                                          showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}

fileprivate func makeMembersByStatusResult(members: [Member]) -> String {
    var csvReturn = "name,date-joined,recep-type,from-church"
    let strings = members.map { member in
        "\"\(memberName(member: member))\",\(dateJoined(member: member)),\(receptionType(member: member)),\"\(churchFrom(member: member))\""
    }
    csvReturn = strings.reduce(csvReturn) { thusFar, newString in
        "\(thusFar)\n\(newString)"
    }
    return csvReturn
}
