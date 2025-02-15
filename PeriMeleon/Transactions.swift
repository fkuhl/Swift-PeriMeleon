//
//  Transactions.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/15/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct TransactionsView: View {
    var member: Member
    
    var body: some View {
        //Don't put these inside a Vstack or List: in context they're already in a List
        ForEach(member.transactions, id: \.self) { transaction in
            TransactionRowView(item: transaction)
        }
    }
}

struct TransactionRowView: View {
    var item: PMDataTypes.Transaction
    
    var body: some View {
        NavigationLink(destination: TransactionView(transaction: item)) {
            Text("\(dateForDisplay(item.date))  \(item.type.rawValue)")
                .font(.body)
        }
    }
}

struct TransactionView: View {
    var transaction: PMDataTypes.Transaction
    var body: some View {
        List {
            TextAttributeView(caption: "date", text: dateForDisplay(transaction.date))
            TextAttributeView(caption: "type", text: transaction.type.rawValue)
            if !nugatory(transaction.authority) {
                TextAttributeView(caption: "authority", text: transaction.authority)
            }
            if !nugatory(transaction.church) {
                TextAttributeView(caption: "church", text: transaction.church)
            }
            if !nugatory(transaction.comment) {
                TextAttributeView(caption: "comment", text: transaction.comment)
            }
        }
        .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        Text("Transaction")
                    })})
    }
}

//struct Transactions_Previews: PreviewProvider {
//    static var previews: some View {
//        Transactions()
//    }
//}
