//
//  QueriesView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/17/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct QueriesView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    
    var body: some View {
        Section(header: Text("Phone list").font(.headline)) {
            NavigationLink(destination: PhonelistView()) {
                LinkText(label: "Phone list")
            }
        }
        Section(header: Text("Members").font(.headline)) {
            NavigationLink(destination: MembersByStatusView()) {
                LinkText(label: "Members by status")
            }
            NavigationLink(destination: MembersByAgeView()) {
                LinkText(label: "Members by age")
            }
            NavigationLink(destination: BirthdaysView()) {
                LinkText(label: "Birthdays")
            }
            NavigationLink(destination: BaptismsView()) {
                LinkText(label: "Baptisms")
            }
            NavigationLink(destination: TransactionsQuery()) {
                LinkText(label: "Transactions for statistics")
            }
        }
    }

    fileprivate struct LinkText: View {
        var label: String
        
        var body: some View {
            HStack {
                Text("\(label) \(Image(systemName: "chevron.forward"))").font(.body)
                Spacer()
            }
        }
    }
}

struct QueriesView_Previews: PreviewProvider {
    static var previews: some View {
        QueriesView()
        .previewLayout(.fixed(width: 1068, height: 834))
    }
}
