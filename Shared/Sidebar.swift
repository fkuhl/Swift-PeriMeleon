//
//  Sidebar.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/30/21.
//

import SwiftUI

struct Sidebar: View {
    @State private var linkSelection: WorkflowLink? = nil

    var body: some View {
        List {
            NavigationLink(destination: MembersView()) {
                Label("Members", systemImage: "person.2")
            }
            NavigationLink(destination: HouseholdsView()) {
                Label("Households", systemImage: "house")
            }
            DisclosureGroup(content: {
                WorkflowsView()
            }, label: {
                Label("Workflows", systemImage: "gearshape.2")
            }).frame(width: 300)
            DisclosureGroup(content: {
                QueriesView()
            }, label: {
                Label("Queries", systemImage: "magnifyingglass")
            }).frame(width: 300)
        }
        .listStyle(SidebarListStyle())
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
        
    }
}
