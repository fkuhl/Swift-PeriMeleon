//
//  PhonelistResultsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistResultsView: View {
    @EnvironmentObject var document: PeriMeleonDocument
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
    ]

    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
                    Text("Phone").font(.caption)
                    Text("Email").font(.caption)
                    ForEach(members) {
                        Text(memberName(member: $0)).font(.body)
                        Text(phone(member: $0)).font(.body)
                        Text(email(member: $0)).font(.body)
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
            let maker = PhonelistMaker(document: document)
            resultsAsData = maker.make(from: members).data(using: .utf8)!
            queryResults.setCSV(results: resultsAsData)
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up").font(.body)
        }.padding(20)
    }
    
    ///Export to file
    private var macShare: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                do {
                    let maker = PhonelistMaker(document: document)
                    resultsAsData = maker.make(from: members).data(using: .utf8)!
                    let fileManager = FileManager.default
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-phone-list.csv"
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

    private func memberName(member: Member) -> String {
        return member.displayName()
    }

    private func phone(member: Member) -> String {
        if !nugatory(member.mobilePhone) { return member.mobilePhone! }
        let household = document.household(byId: member.household)
        if let address = household.address, !nugatory(address.homePhone) {
            return address.homePhone!
        } else {
            return ""
        }
    }

    private func email(member: Member) -> String {
        if !nugatory(member.eMail) { return member.eMail! }
        let household = document.household(byId: member.household)
        if let address = household.address, !nugatory(address.email) {
            return address.email!
        } else {
            return ""
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
            .environmentObject(mockDocument)
    }
}
