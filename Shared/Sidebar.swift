//
//  Sidebar.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/30/21.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var linkSelection: WorkflowLink? = nil

    var body: some View {
        List {
            NavigationLink(destination: MembersView().environmentObject(document)) {
                Label("Members", systemImage: "person.2")
            }
            NavigationLink(destination: HouseholdsView().environmentObject(document)) {
                Label("Households", systemImage: "house")
            }
            DisclosureGroup(content: {
                WorkflowsView()
            }, label: {
                Label("Workflows", systemImage: "gearshape.2")
            })
            DisclosureGroup(content: {
                QueriesView()
            }, label: {
                Label("Queries", systemImage: "magnifyingglass")
            })
        }
        .listStyle(SidebarListStyle())
    }
}


struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
            .environmentObject(mockDocument)
    }
}
