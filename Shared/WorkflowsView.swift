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
    case familyDismissed
    case newAddition
    case profession
    case moveToHousehold
    case dataChecker
    case information
}

struct WorkflowsView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @ObservedObject var moveToHouseholdAccumulator = MoveToHouseholdAccumulator()
    @State private var linkSelection: WorkflowLink? = nil
    
    var body: some View {
        Section(header: Text("Families").font(.headline)) {
            VStack(alignment: .leading) {
                NavigationLink(destination: FamilyJoinView(linkSelection: $linkSelection),
                               tag: .familyJoins,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .familyJoins,
                               label: "Family joins")
                }
                Caption(text: "Family joins church. A new household is created. "
                        + "Enter the reception data once for the entire family. "
                        + "Enter the head of the household, then edit the new household, "
                        + "adding spouse and dependents.")
            }
            VStack(alignment: .leading) {
                NavigationLink(destination: FamilyDismissedView(linkSelection: $linkSelection),
                               tag: .familyDismissed,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .familyDismissed,
                               label: "Family dismissed")
                }
                Caption(text: "Family is dismissed or dismissal is pending. "
                        + "Enter date and comment "
                        + "and all members of the family are changed.")
            }.padding(.top, 20)
        }
        Section(header: Text("Members").font(.headline)) {
            VStack(alignment: .leading) {
                NavigationLink(destination: NewAddition(linkSelection: $linkSelection),
                               tag: .newAddition,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .newAddition, label: "New addition to household")
                }
                Caption(text: "Household welcomes new member.")
            }
            VStack(alignment: .leading) {
                NavigationLink(destination: ProfessionView(linkSelection: $linkSelection),
                               tag: .profession,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .profession, label: "Profession of faith")
                }
                Caption(text: "Non-communing member makes profession and becomes communing.")
            }.padding(.top, 20)
            VStack(alignment: .leading) {
                NavigationLink(destination: MoveToHouseholdView(),
                               tag: .moveToHousehold,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .moveToHousehold, label: "Member moves to different household")
                }
                Caption(text: "Member of one household moves to establish their "
                            + "own household.")
            }.padding(.top, 20)
        }
        Section(header: Text("Miscellaneous").font(.headline)) {
            VStack(alignment: .leading) {
                NavigationLink(destination: dataCheckerView,
                               tag: .dataChecker,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .dataChecker, label: "Data checker")
                }
                Caption(text: "For each member, check that member's status "
                            + "and last transaction are consistent.")
            }
            VStack(alignment: .leading) {
                NavigationLink(destination: InformationView(),
                               tag: .information,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .information, label: "Information")
                    
                }
                Caption(text: "Statistics on the data; app build information.")
            }.padding(.top, 20)
        }
    }

    fileprivate struct LinkButton: View {
        @Binding var linkSelection: WorkflowLink?
        var link: WorkflowLink
        var label: String
        
        var body: some View {
            HStack {
                Button(action: { linkSelection = link }) {
                    Text("\(label) \(Image(systemName: "chevron.forward"))").font(.body)
                }
                Spacer()
            }
        }
    }
    
    fileprivate struct Caption: View {
        var text: String
        
        var body: some View {
            Text(text)
                .font(.caption)
                .lineLimit(nil)
                .frame(width: 150)
        }
    }

    private var dataCheckerView: some View {
        return DataCheckerView(dataChecker: DataChecker(document: document))
    }
}

struct WorkflowsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkflowsView()
            .previewLayout(PreviewLayout.fixed(width: 1024, height: 768))
            .environmentObject(mockDocument)
    }
}
