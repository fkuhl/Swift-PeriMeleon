//
//  TransactionsQuery.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/26/21.
//

import SwiftUI
import PMDataTypes

///If it's Identifiable, it's easier to display.
struct TransactionQueryRecord: Identifiable {
    var id: UUID
    var name: String
    var type: TransactionType
    var date: Date
    var status: MemberStatus
}

struct TransactionsQuery: View {
    private static let titleDateFormatter = makeTitleDateFormatter()
    @State var earliest: Date = yearEarlier()
    @State var latest: Date = Date()
    @State var transactions = [TransactionQueryRecord]()
    @State var showingResults = false
    
    var body: some View {
        VStack {
            if !showingResults {
                TransactionsQueryEntry(earliest: $earliest,
                                  latest: $latest,
                                  transactions: $transactions,
                                   showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                TransactionsQueryResults(title: resultsTitleString,
                                     transactions: $transactions,
                                     showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Transactions between dates:")
            }
        }
    }
    
    private var resultsTitleString: String {
        "\(transactions.count) Transaction\(transactions.count == 1 ? "" : "s") Between "
            + "\(Self.titleDateFormatter.string(from: earliest))"
        + " and \(Self.titleDateFormatter.string(from: latest))"
    }
}

fileprivate func yearEarlier() -> Date {
    let components = DateComponents(year: -1)
    return Calendar.current.date(byAdding: components, to: Date())!
}

fileprivate func makeTitleDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}

struct TransactionsQuery_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsQuery()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
            .environmentObject(mockDocument)
    }
}
