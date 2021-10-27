//
//  TransactionQueryResult.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/26/21.
//

import SwiftUI
import PMDataTypes

struct TransactionsQueryResults: View {
    var title: String
    @Binding var transactions: [TransactionQueryRecord]
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
                    Text("Name").font(.caption)
                    Text("Type").font(.caption)
                    Text("Date").font(.caption)
                    Text("Status").font(.caption)
                    ForEach(transactions) {
                        Text($0.name).font(.body)
                        Text($0.type.rawValue).font(.body)
                        Text(dateFormatter.string(from: $0.date)).font(.body)
                        Text($0.status.rawValue).font(.body)
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
            self.transactions = []
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
            resultsAsData = makeTransactionsResult(records: transactions)
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
                    let resultsAsData = makeTransactionsResult(records: transactions).data(using: .utf8)!
                    let fileManager = FileManager.default
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-transactions.csv"
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
//        VStack(alignment: .trailing) {
//            Button(action: {
//                let pasteboard = UIPasteboard.general
//                pasteboard.string = makeTransactionsResult(records: transactions)
//            }) {
//                Image(systemName: "arrow.up.doc.on.clipboard").font(.body)
//            }.padding(.top, 20).padding(.bottom, 5).padding(.trailing, 20)
//            Text("Copy to paste buffer. Paste into file.").font(.body).italic()
//                .padding(.trailing, 20)
//        }
    }
}

fileprivate func makeTransactionsResult(records: [TransactionQueryRecord]) -> String {
    var csvReturn = "name,type,date,status"
    let strings = records.map { record in
        "\"\(record.name)\",\"\(record.type.rawValue)\",\"\(dateFormatter.string(from: record.date))\",\"\(record.status.rawValue)\""
    }
    csvReturn = strings.reduce(csvReturn) { thusFar, newString in
        "\(thusFar)\n\(newString)"
    }
    return csvReturn
}

struct TransactionQueryResult_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsQueryResults(title: "Transaction Results",
                                transactions: .constant([TransactionQueryRecord]()),
                                showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
