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
    @State private var showingDocumentPicker = false
    @State private var temporaryURL = URL(fileURLWithPath: "") //placeholder
    @ObservedObject private var queryResults = QueryResults.sharedInstance
    @State private var resultsAsData = Data()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
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
                    Text("Transaction date").font(.caption)
                    Text("Transaction type").font(.caption)
                    Text("Authority").font(.caption)
                    Text("From/to church").font(.caption)
                    Text("Comment").font(.caption)
                    ForEach(members) {
                        Text(memberName(member: $0)).font(.body)
                        Text(transactionDate(member: $0)).font(.body)
                        Text(transactionType(member: $0)).font(.body)
                        Text(authority(member: $0)).font(.body)
                        Text(churchFrom(member: $0)).font(.body)
                        Text(comment(member: $0)).font(.body)
                    }
                }
            }.padding()
        }
#if targetEnvironment(macCatalyst)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentExportPicker(fileURL: $temporaryURL)
        }
#else
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
        }
#endif

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
            resultsAsData = makeMembersByStatusResult(members: self.members)
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
                do {
                    let resultsAsData = makeMembersByStatusResult(members: self.members).data(using: .utf8)!
                    let fileManager = FileManager.default
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-members-by-status.csv"
                    temporaryURL = fileManager.temporaryDirectory.appendingPathComponent(suggestedFileName)
                    NSLog("temp URL: \(temporaryURL)")
                    try resultsAsData.write(to: temporaryURL)
                    showingDocumentPicker = true
                } catch let error {
                    NSLog("error writing temp: \(error.localizedDescription)")
                    return
                }
            }) {
                Image(systemName: "square.and.arrow.down").font(.headline)
            }.padding(.top, 20).padding(.bottom, 5).padding(.trailing, 20)
            Text("Save to file.").font(.body).italic()
                .padding(.trailing, 20)
        }
    }
}

private func memberName(member: Member) -> String {
    return member.displayName()
}

private func transactionDate(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    let date = member.transactions.last!.date
    if date == nil { return "" }
    return dateFormatter.string(from: date!)
}

private func transactionType(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions.last!.type.rawValue
}

private func authority(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions.last!.authority ?? ""
}

private func churchFrom(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions.last!.church ?? ""
}

private func comment(member: Member) -> String {
    guard member.transactions.count > 0 else { return "" }
    return member.transactions.last!.comment ?? ""
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
    var csvReturn = "name,date,type,authority,from-to-church,comment"
    let strings = members.map { member in
        "\"\(memberName(member: member))\",\(transactionDate(member: member)),\(transactionType(member: member)),\(authority(member: member)),\"\(churchFrom(member: member)),\"\(comment(member: member))\""
    }
    csvReturn = strings.reduce(csvReturn) { thusFar, newString in
        "\(thusFar)\n\(newString)"
    }
    return csvReturn
}
