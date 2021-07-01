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
        Section(header: Text("Phone list").font(.headline)) {
            NavigationLink(destination: PhonelistView(document: $document)) {
                LinkText(label: "Phone list")
            }
        }
        Section(header: Text("Members").font(.headline)) {
            NavigationLink(destination: MembersByStatusView(document: $document)) {
                LinkText(label: "Members by status")
            }
            NavigationLink(destination: MembersByAgeView(document: $document)) {
                LinkText(label: "Members by age")
            }
            NavigationLink(destination: BirthdaysView(document: $document)) {
                LinkText(label: "Birthdays")
            }
            NavigationLink(destination: BaptismsView(document: $document)) {
                LinkText(label: "Baptisms")
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
        QueriesView(document: mockDocument)
        .previewLayout(.fixed(width: 1068, height: 834))
    }
}
