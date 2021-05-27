//
//  WorkflowsView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

fileprivate enum Link: String {
    case familyJoins
    case moveToHousehold
    case dataChecker
}

struct WorkflowsView: View {
    @Binding var document: PeriMeleonDocument
    @ObservedObject var moveToHouseholdAccumulator = MoveToHouseholdAccumulator()
    @State var linkSelection: String? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Families")) {
                    NavigationLink(destination: FamilyJoinView(document: $document,
                                                               linkSelection: $linkSelection),
                                   tag: Link.familyJoins.rawValue,
                                   selection: $linkSelection) {
                        Button(action: {
                            self.linkSelection = Link.familyJoins.rawValue
                        }) {
                            Text("Family joins").font(.body)
                        }
                    }
                }
                Section(header: Text("Members")) {
                    NavigationLink(destination: MoveToHouseholdView(document: $document),
                                   tag: Link.moveToHousehold.rawValue,
                                   selection: $linkSelection) {
                        Button(action: {
                            // TODO initialize move accum
                            self.linkSelection = Link.moveToHousehold.rawValue
                        }) {
                            Text("Member moves to different household").font(.body)
                        }
                    }
                }
                Section(header: Text("Miscellaneous")) {
                    NavigationLink(destination: DataCheckerView(document: $document,
                                                                dataChecker: DataChecker(document: $document)),
                                   tag: Link.dataChecker.rawValue,
                                   selection: $linkSelection) {
                        Button(action: {
                            self.linkSelection = Link.dataChecker.rawValue
                        }) {
                            Text("Data checker").font(.body)
                        }
                    }
                }
            }
            .navigationBarTitle("Workflow Types")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
        }
            //A little odd having this here, but make sense:
            //this object will be referred to throughout the navigation.
        .environmentObject(moveToHouseholdAccumulator)
    }
}

struct WorkflowsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowsView(document: mockDocument)
    }
}
