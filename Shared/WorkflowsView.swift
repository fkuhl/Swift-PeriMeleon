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
    case memberHouseholdChecker
    case dataChecker
    case information
    case removeMember
    case removeHousehold
    case repairMember
    case memberMarriesMember
    case memberDies
}

struct WorkflowsView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var linkSelection: WorkflowLink? = nil
    
    var body: some View {
        DisclosureGroup("Families") {
            VStack(alignment: .leading) {
                NavigationLink(destination: FamilyJoinView(linkSelection: $linkSelection).environmentObject(document),
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
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: FamilyDismissedView(linkSelection: $linkSelection).environmentObject(document),
                               tag: .familyDismissed,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .familyDismissed,
                               label: "Family dismissed")
                }
                Caption(text: "Family is dismissed or dismissal is pending. "
                        + "Enter date and comment "
                        + "and all members of the family are changed.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: MemberMarriesMember(linkSelection: $linkSelection).environmentObject(document),
                               tag: .memberMarriesMember,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .memberMarriesMember,
                               label: "Two members marry")
                }
                Caption(text: "Two members marry, creating new household.")
            }
        }
        DisclosureGroup("Members") {
            VStack(alignment: .leading) {
                NavigationLink(destination: NewAddition(linkSelection: $linkSelection).environmentObject(document),
                               tag: .newAddition,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .newAddition,
                               label: "New addition to household")
                }
                Caption(text: "Household welcomes new member.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: ProfessionView(linkSelection: $linkSelection).environmentObject(document),
                               tag: .profession,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection,
                               link: .profession,
                               label: "Profession of faith")
                }
                Caption(text: "Non-communing member makes profession and becomes communing.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: MoveToHouseholdView().environmentObject(document),
                               tag: .moveToHousehold,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .moveToHousehold, label: "Moves to another household")
                }
                Caption(text: "Member moves to another household, or establishes their own household.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: MemberDiesView().environmentObject(document),
                               tag: .memberDies,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .memberDies, label: "Member dies")
                }
                Caption(text: "Member dies.")
            }
        }
        DisclosureGroup("Miscellaneous") {
            VStack(alignment: .leading) {
                NavigationLink(destination: InformationView().environmentObject(document),
                               tag: .information,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .information, label: "Information")
                    
                }
                Caption(text: "Statistics on the data; app build information.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: MemberHouseholdCheckerView().environmentObject(document),
                               tag: .memberHouseholdChecker,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .memberHouseholdChecker, label: "Member-household consistency")
                }
                Caption(text: "For each active member, check that they are a member of that household and that household only.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: dataCheckerView,
                               tag: .dataChecker,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .dataChecker, label: "Status-transaction consistency")
                }
                Caption(text: "For each active member, check that member's status "
                            + "and last transaction are consistent.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: RemoveMemberView().environmentObject(document),
                               tag: .removeMember,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .removeMember, label: "Remove member")
                    
                }
                Caption(text: "Remove member from data. This is ONLY for maintenance, and never for normal use.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: RemoveHouseholdView().environmentObject(document),
                               tag: .removeHousehold,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .removeHousehold, label: "Remove household")
                    
                }
                Caption(text: "Remove household from data. This is ONLY for maintenance, and never for normal use.")
            }
#if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
#endif
            VStack(alignment: .leading) {
                NavigationLink(destination: RepairMemberView().environmentObject(document),
                               tag: .repairMember,
                               selection: $linkSelection) {
                    LinkButton(linkSelection: $linkSelection, link: .repairMember, label: "Repair member")
                    
                }
                Caption(text: "Repair member's household link. This is ONLY for maintenance, and never for normal use.")
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
                    Text("\(label) \(Image(systemName: "chevron.forward"))")
                        .font(.body)
                    ///https://stackoverflow.com/questions/56593120/how-do-you-create-a-multi-line-text-inside-a-scrollview-in-swiftui/56604599#56604599
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
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
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(10)
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
