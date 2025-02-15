//
//  TransactionsQueryEntry.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/26/21.
//

import SwiftUI

struct TransactionsQueryEntry: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var earliest: Date
    @Binding var latest: Date
    @Binding var transactions: [TransactionQueryRecord]
    @Binding var showingResults: Bool
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Text("Earliest date:").frame(width: 150).font(.body)
                DatePicker(selection: $earliest, in: ...Date(), displayedComponents: .date) {
                    Text("").font(.body)
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Latest date:").frame(width: 150).font(.body)
                DatePicker(selection: $latest, in: ...Date(), displayedComponents: .date) {
                    Text("").font(.body)
                }
                Spacer()
            }
            HStack {
                Spacer()
                SolidButton(text: "Run Query", action: runQuery)
                Spacer()
            }.padding()
        }
    }

    func runQuery() {
        NSLog("run query")
        document.members.forEach() { member in
            let transactionsInRange = member.transactions.filter { transaction in
                guard let date = transaction.date else { return false }
                return earliest <= date && date <= latest
            }
            for transaction in transactionsInRange {
                transactions.append(
                    TransactionQueryRecord(id: UUID(),
                                           name: member.fullName(),
                                           type: transaction.type,
                                           date: transaction.date ?? Date(),//shouldn't happen!
                                           status: member.status))
            }
        }
        transactions.sort { $0.type.rawValue < $1.type.rawValue }
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.showingResults = true
        }
    }
}

struct TransactionsQueryEntry_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsQueryEntry(earliest: .constant(Date()),
        latest: .constant(Date()),
        transactions: .constant([TransactionQueryRecord]()),
        showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")    }
}
