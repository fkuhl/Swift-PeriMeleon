//
//  QueriesView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/17/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct QueriesView: View {
    @Binding var document: PeriMeleonDocument

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Phone list")) {
                    NavigationLink(destination: PhonelistView(document: $document)) {
                        Text("Phone list").font(.body)
                    }
                }
                Section(header: Text("Members")) {
                    NavigationLink(destination: BirthdaysView(document: $document)) {
                        Text("Birthdays").font(.body)
                    }
                    NavigationLink(destination: MembersByStatusView(document: $document)) {
                        Text("Members by status").font(.body)
                    }
                    NavigationLink(destination: MembersByAgeView(document: $document)) {
                        Text("Members by age").font(.body)
                    }
                }
            }
            .navigationBarTitle("Queries")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
        }
    }
}

struct QueriesView_Previews: PreviewProvider {
    static var previews: some View {
        QueriesView(document: mockDocument)
        .previewLayout(.fixed(width: 1068, height: 834))
    }
}
