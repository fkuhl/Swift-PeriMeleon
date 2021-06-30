//
//  Sidebar.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/30/21.
//

import SwiftUI

struct Sidebar: View {
    @Binding var document: PeriMeleonDocument

    var body: some View {
        List {
            NavigationLink(destination: MembersView(document: $document)) {
                Label("Members", systemImage: "person.2")
            }
            NavigationLink(destination: HouseholdsView(document: $document)) {
                Label("Households", systemImage: "house")
            }
            NavigationLink(destination: WorkflowsView(document: $document)) {
                Label("Workflows", systemImage: "gearshape.2")
            }
            NavigationLink(destination: QueriesView(document: $document)) {
                Label("Queries", systemImage: "magnifyingglass")
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(document: mockDocument)
        
    }
}
