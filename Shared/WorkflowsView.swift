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
    @ObservedObject var moveToHouseholdAccumulator = MoveToHouseholdAccumulator()
    @State private var linkSelection: WorkflowLink? = nil
    
    var body: some View {
        Section(header: Text("Families").font(.headline)) {
            NavigationLink(destination: FamilyJoinView(linkSelection: $linkSelection),
                           tag: .familyJoins,
                           selection: $linkSelection) {
                LinkButton(linkSelection: $linkSelection, link: .familyJoins, label: "Family joins")
            }
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

    private var dataCheckerView: some View {
        @EnvironmentObject var model: Model
        return DataCheckerView(dataChecker: DataChecker(model: model))
    }
}

struct WorkflowsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkflowsView()
                .previewLayout(PreviewLayout.fixed(width: 1024, height: 768))
        }
    }
}
