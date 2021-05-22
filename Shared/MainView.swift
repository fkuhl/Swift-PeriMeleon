//
//  MainView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

struct MainView: View {
    @Binding var document: PeriMeleonDocument
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            MembersView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Members")
                }
                .tag(0)
            HouseholdsView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "house")
                    Text("Households")
                }
                .tag(1)
            WorkflowsView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("Workflows")
                }
                .tag(2)
            QueriesView(document: $document)
                .font(.title)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Queries")
                }
                .tag(3)
        }
    }
}
