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
        DisclosureGroup("Phone list & directory") {
            VStack(alignment: .leading) {
                NavigationLink(destination: PhonelistView().environmentObject(document)) {
                    LinkText(label: "Phone list")
                }
                Caption(text: "List of contact info for active members, "
                            + "in comma-separated values format, "
                            + "suitable for importing into contacts app.")
            }.padding(.bottom, 10)
            VStack(alignment: .leading) {
                NavigationLink(destination: DirectoryView().environmentObject(document)) {
                    LinkText(label: "Directory")
                }
                Caption(text: "Directory of active members")
            }
        }
        DisclosureGroup("Members") {
            VStack(alignment: .leading) {
                NavigationLink(destination: MembersByStatusView().environmentObject(document)) {
                    LinkText(label: "Members by status")
                }
                Caption(text: "Query members by status and residency.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: MembersByAgeView().environmentObject(document)) {
                    LinkText(label: "Members by age")
                }
                Caption(text: "Query members by age as of a given date.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: BirthdaysView().environmentObject(document)) {
                    LinkText(label: "Birthdays")
                }
                Caption(text: "Generate list of active embers with birthdays in a given month.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: BaptismsView().environmentObject(document)) {
                    LinkText(label: "Baptisms")
                }
                Caption(text: "List all baptisms recorded within a given range of dates.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: TransactionsQuery().environmentObject(document)) {
                    LinkText(label: "Transactions in date range")
                }
                Caption(text: "For annual statistical report: list all transactions that "
                            + "occurred in a given range of dates.")
            }
        }
    }
    
    fileprivate struct LinkText: View {
        var label: String
        
        var body: some View {
            HStack {
                Button(action: {} ) {
                    Text("\(label) \(Image(systemName: "chevron.forward"))")
                        .font(.body)
                    ///https://stackoverflow.com/questions/56593120/how-do-you-create-a-multi-line-text-inside-a-scrollview-in-swiftui/56604599#56604599
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
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
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
    }
}

struct QueriesView_Previews: PreviewProvider {
    static var previews: some View {
        QueriesView()
        .previewLayout(.fixed(width: 1068, height: 834))
    }
}
