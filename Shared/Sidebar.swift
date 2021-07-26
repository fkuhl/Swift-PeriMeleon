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
            }).frame(width: sidebarLabelWidth)
            DisclosureGroup(content: {
                QueriesView()
            }, label: {
                Label("Queries", systemImage: "magnifyingglass")
            }).frame(width: sidebarLabelWidth)
        }
        .listStyle(SidebarListStyle())
    }
}

let sidebarLabelWidth: CGFloat = 210


struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
            .environmentObject(mockDocument)
    }
}
