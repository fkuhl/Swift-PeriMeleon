//
//  TransactionEditView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/29/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct TransactionsEditView: View {
    @Binding var member: Member
    
    var body: some View {
        ForEach(0..<member.transactions.count, id: \.self) {
            TransactionEditRowView(member: self.$member, index: $0)
        }
    }
}

struct TransactionsEditAddView: View {
    @Binding var member: Member
    
    var body: some View {
        Button(action: {
            appendEmptyTransaction(to: self.$member)
        }) {
            Image(systemName: "plus").font(.body)
        }
    }
}

fileprivate func appendEmptyTransaction(to member: Binding<Member>) {
    member.transactions.wrappedValue.append(PMDataTypes.Transaction())
}

struct TransactionEditRowView: View {
    @Binding var member: Member
    var index: Int

    var body: some View {
        NavigationLink(destination: TransactionEditView(member: $member, index: index)) {
            Text("\(dateForDisplay(member.transactions[index].date))  \(member.transactions[index].type.rawValue)")
                .font(.body)
        }
    }
}

struct TransactionEditView: View {
    @Binding var member: Member
    var index: Int

    var body: some View {
        Form {
            Section {
                EditOptionalDateView(caption: "date:", date: $member.transactions[index].date)
                EditTransactionTypeView(caption: "type:", transactionType: $member.transactions[index].type)
                EditOptionalTextView(caption: "authority:", text: $member.transactions[index].authority)
                EditOptionalTextView(caption: "church:", text: $member.transactions[index].church)
                EditOptionalTextView(caption: "comment:", text: $member.transactions[index].comment)
            }
        }
    }
}

//struct TransactionEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionEditView()
//    }
//}
