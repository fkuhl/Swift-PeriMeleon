//
//  WorkflowsView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

enum WorkflowLink {
    case familyJoins
    case moveToHousehold
    case dataChecker
    case information
}

struct WorkflowsView: View {
    @Binding var document: PeriMeleonDocument
    @ObservedObject var moveToHouseholdAccumulator = MoveToHouseholdAccumulator()
    @State private var linkSelection: WorkflowLink? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Families")) {
                    NavigationLink(destination: FamilyJoinView(document: $document,
                                                               linkSelection: $linkSelection),
                                   tag: .familyJoins,
                                   selection: $linkSelection) {
                        Button(action: { self.linkSelection = .familyJoins }) {
                            Text("Family joins").font(.body)
                        }
                    }
                }
                Section(header: Text("Members")) {
                    NavigationLink(destination: MoveToHouseholdView(document: $document),
                                   tag: .moveToHousehold,
                                   selection: $linkSelection) {
                        Button(action: {
                            // TODO initialize move accum
                            self.linkSelection = .moveToHousehold
                        }) {
                            Text("Member moves to different household").font(.body)
                        }
                    }
                }
                Section(header: Text("Miscellaneous")) {
                    NavigationLink(destination: dataCheckerView,
                                   tag: .dataChecker,
                                   selection: $linkSelection) {
                        Button(action: { self.linkSelection = .dataChecker }) {
                            Text("Data checker").font(.body)
                        }
                    }
                    NavigationLink(destination: InformationView(document: $document),
                                   tag: .information,
                                   selection: $linkSelection) {
                        Button(action: { self.linkSelection = .information }) {
                            Text("Information").font(.body)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text("Workflow Types")
                        })})
            .listStyle(GroupedListStyle())
        }
            //A little odd having this here, but make sense:
            //this object will be referred to throughout the navigation.
        .environmentObject(moveToHouseholdAccumulator)
    }
    
    private var dataCheckerView: some View {
        DataCheckerView(document: $document,
                        dataChecker: DataChecker(document: $document))
    }
}

struct WorkflowsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkflowsView(document: mockDocument)
                .previewLayout(PreviewLayout.fixed(width: 1024, height: 768))
        }
    }
}
