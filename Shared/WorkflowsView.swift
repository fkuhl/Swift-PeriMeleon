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
            NavigationLink(destination: MoveToHouseholdView(),
                           tag: .moveToHousehold,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .moveToHousehold, label: "Member moves to different household")
            }
        }
        Section(header: Text("Miscellaneous").font(.headline)) {
            NavigationLink(destination: dataCheckerView,
                           tag: .dataChecker,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .dataChecker, label: "Data checker")
            }
            NavigationLink(destination: InformationView(),
                           tag: .information,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .information, label: "Information")
                
            }
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
