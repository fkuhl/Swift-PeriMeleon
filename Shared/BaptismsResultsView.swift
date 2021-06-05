//
//  BaptismsResultsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 6/5/21.
//

import SwiftUI
import PMDataTypes

struct BaptismsResultsView: View {
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance
    @State private var resultsAsData = Data()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                clearButton
                Spacer()
                Text(title).font(.title)
                Spacer()
                #if targetEnvironment(macCatalyst)
                macShare
                #else
                iosShare
                #endif
            }
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Baptism").font(.caption)
                    ForEach(members, id: \.id) {
                        Text(memberName(member: $0)).font(.body)
                        Text(baptism(member: $0)).font(.body)
                    }
                }
            }.padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
        }
    }
    
    private var clearButton: some View {
        Button(action: {
            self.members = []
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                self.showingResults = false
            }
        }) {
            Text("Clear").font(.body)
        }.padding(20)
    }
    
    ///Bring up share sheet
    private var iosShare: some View {
        Button(action: {
            resultsAsData = makeBaptismResult(members: self.members)
                .data(using: .utf8)!
            queryResults.setCSV(results: resultsAsData)
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up").font(.body)
        }.padding(20)
    }
    
    ///Copy to pasteboard
    private var macShare: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                let pasteboard = UIPasteboard.general
                pasteboard.string = makeBaptismResult(members: self.members)
            }) {
                Image(systemName: "arrow.up.doc.on.clipboard").font(.body)
            }.padding(.top, 20).padding(.bottom, 5).padding(.trailing, 20)
            Text("Copy to paste buffer. Paste into file.").font(.body).italic()
                .padding(.trailing, 20)
        }
    }
}

private func memberName(member: Member) -> String {
    return member.fullName()
}

private func baptism(member: Member) -> String {
   return member.baptism ?? ""
}

struct BaptismsResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let mocks = [mockMember1, mockMember2]
        BaptismsResultsView(title: "This is The Title",
                            members: .constant(mocks),
                            showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}

fileprivate func makeBaptismResult(members: [Member]) -> String {
    var csvReturn = "name,baptism"
    let strings = members.map { member in
        "\"\(memberName(member: member))\",\"\(baptism(member: member))\""
    }
    csvReturn = strings.reduce(csvReturn) { thusFar, newString in
        "\(thusFar)\n\(newString)"
    }
    return csvReturn
}
