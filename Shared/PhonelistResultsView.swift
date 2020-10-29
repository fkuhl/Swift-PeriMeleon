//
//  PhonelistResultsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistResultsView: View {
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance

    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

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
//                    queryResults.toBeShared = [makeMembersByStatusResult(members: members)]
//                    NSLog("results: \(queryResults.toBeShared[0])")
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").font(.body)
                }.padding(20)
            }
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Phone").font(.caption)
                    Text("Email").font(.caption)
//                    ForEach(members, id: \.id) {
//                        Text(memberName(member: $0)).font(.body)
//                        Text(dateJoined(member: $0)).font(.body)
//                        Text(receptionType(member: $0)).font(.body)
//                        Text(churchFrom(member: $0)).font(.body)
//                    }
                }
            }.padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
                .debugPrint("queryResults element has \((queryResults.toBeShared[0] as! NSString).length)")
        }
    }
}

struct PhonelistResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistResultsView(title: "Phone list",
                             members: .constant([mockMember1, mockMember2]),
                             showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
