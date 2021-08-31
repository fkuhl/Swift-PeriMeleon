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
        DisclosureGroup(content: {
            VStack(alignment: .leading) {
                NavigationLink(destination: PhonelistView()) {
                    LinkText(label: "Phone list")
                }
                Caption(text: "List of contact info for active members, "
                            + "in comma-separated values format, "
                            + "suitable for importing into contacts app.")
            }
        }, label: {
            Text("Phone list")
        })
        DisclosureGroup(content: {
            VStack(alignment: .leading) {
                NavigationLink(destination: MembersByStatusView()) {
                    LinkText(label: "Members by status")
                }
                Caption(text: "Query members by status and residency.")
            }
            VStack(alignment: .leading) {
                NavigationLink(destination: MembersByAgeView()) {
                    LinkText(label: "Members by age")
                }
                Caption(text: "Query members by age as of a given date.")
            }.padding(.top, 20)
            VStack(alignment: .leading) {
                NavigationLink(destination: BirthdaysView()) {
                    LinkText(label: "Birthdays")
                }
                Caption(text: "Generate list of active embers with birthdays in a given month.")
            }.padding(.top, 20)
            VStack(alignment: .leading) {
                NavigationLink(destination: BaptismsView()) {
                    LinkText(label: "Baptisms")
                }
                Caption(text: "List all baptisms recorded within a given range of dates.")
            }.padding(.top, 20)
            VStack(alignment: .leading) {
                NavigationLink(destination: TransactionsQuery()) {
                    LinkText(label: "Transactions in date range")
                }
                Caption(text: "For annual statistical report: list all transactions that "
                            + "occurred in a given range of dates.")
            }.padding(.top, 20)
        }, label: {
            Text("Members")
        })
    }

    fileprivate struct LinkText: View {
        var label: String
        
        var body: some View {
            HStack {
                Button(action: {} ) {
                    Text("\(label) \(Image(systemName: "chevron.forward"))").font(.body)
                }
                Spacer()
            }
        }
    }
    
    fileprivate struct Caption: View {
        var text: String
        
        var body: some View {
            Text(text)
                .font(.caption)
                .lineLimit(nil)
                .frame(width: 150)
        }
    }
}

struct QueriesView_Previews: PreviewProvider {
    static var previews: some View {
        QueriesView()
        .previewLayout(.fixed(width: 1068, height: 834))
    }
}
