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
    @State private var showingDeleteAlert = false
    @State private var rowToDelete: Int = 0
    
    var body: some View {
        ForEach(0..<member.transactions.count, id: \.self) {
            TransactionEditRowView(member: self.$member,
                                   index: $0,
                                   showingDeleteAlert: $showingDeleteAlert,
                                   rowToDelete: $rowToDelete)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Delete this transaction?"),
                  message: Text("There is no undo."),
                  primaryButton: .default(Text("Cancel")),
                  secondaryButton: .destructive(Text("Delete Transaction"), action: deleteTransaction))
        }
    }
    
    private func deleteTransaction() {
        var transactions = member.transactions
        transactions.remove(at: rowToDelete)
        //member.transactions = transactions
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
    @Binding var showingDeleteAlert: Bool
    @Binding var rowToDelete: Int
    @State private var showingEdit = false

    var body: some View {
        NavigationLink(destination: TransactionEditView(member: $member,
                                                        index: index,
                                                        showingDeleteAlert: $showingDeleteAlert,
                                                        rowToDelete: $rowToDelete,
                                                       showingEdit: $showingEdit),
                       isActive: $showingEdit) {
            Text("\(dateForDisplay(member.transactions[index].date))  \(member.transactions[index].type.rawValue)")
                .font(.body)
        }
    }
}

struct TransactionEditView: View {
    @Binding var member: Member
    var index: Int
    @Binding var showingDeleteAlert: Bool
    @Binding var rowToDelete: Int
    @Binding var showingEdit: Bool

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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(member.fullName())
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    rowToDelete = index
                    showingDeleteAlert = true
                    showingEdit = false
                }) {
                    Image(systemName: "trash")
                }.padding(.leading)
            }
        }
    }
}

struct TransactionEditView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionEditView(member: .constant(mockMember1),
                            index: 0,
                            showingDeleteAlert: .constant(false),
                            rowToDelete: .constant(0),
                            showingEdit: .constant(false))
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
    }
}
