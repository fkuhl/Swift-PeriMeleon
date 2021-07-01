//
//  Sidebar.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/30/21.
//

import SwiftUI

struct Sidebar: View {
    @Binding var document: PeriMeleonDocument
    @State private var linkSelection: WorkflowLink? = nil

    var body: some View {
        List {
            NavigationLink(destination: MembersView(document: $document)) {
                Label("Members", systemImage: "person.2")
            }
            NavigationLink(destination: HouseholdsView(document: $document)) {
                Label("Households", systemImage: "house")
            }
            DisclosureGroup(content: {
                WorkflowsView(document: $document)
            }, label: {
                Label("Workflows", systemImage: "gearshape.2")
            }).frame(width: 300)
            DisclosureGroup(content: {
                QueriesView(document: $document)
            }, label: {
                Label("Queries", systemImage: "magnifyingglass")
            }).frame(width: 300)
//            NavigationLink(destination: QueriesView(document: $document)) {
//                Label("Queries", systemImage: "magnifyingglass")
//            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(document: mockDocument)
        
    }
}
