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
    @State private var showingDocumentPicker = false
    @State private var temporaryURL = URL(fileURLWithPath: "") //placeholder
    @ObservedObject private var queryResults = QueryResults.sharedInstance
    @State private var resultsAsData = Data()

    let columns = [
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
                    Text("Date of birth").font(.caption)
                    Text("Status").font(.caption)
                    Text("Sex").font(.caption)
                    ForEach(members) {
                        Text(memberName(member: $0)).font(.body)
                        Text(dob(member: $0)).font(.body)
                        Text($0.status.rawValue).font(.body)
                        Text($0.sex.rawValue).font(.body)
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
            resultsAsData = makeMembersByAgeResult(members: self.members)
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
                    let resultsAsData = makeMembersByAgeResult(members: self.members).data(using: .utf8)!
                    let fileManager = FileManager.default
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-members-by-age.csv"
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
