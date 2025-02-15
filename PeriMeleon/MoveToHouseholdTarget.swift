//
//  MoveToHouseholdTarget.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/28/21.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdTarget: View {
    @EnvironmentObject var document: PeriMeleonDocument
    ///The household this is the target for
    var household: NormalizedHousehold
    @Binding var memberId: ID
    ///This binding conveyes the target household back to MoveToHouseholdView.
    @Binding var targetHousehold: NormalizedHousehold
    @Binding var moveToHouseholdState: MoveToHouseholdState
    @Binding var showingSheet: Bool
    ///Next 3 are used by drop and disclosure gp; I don't use
    @State private var droppedOnSpouse = false
    @State private var droppedOnOther = false
    @State private var isExpanded = false

    var body: some View {
        Text(household.name ?? "[none]")
            .onDrop(of: ["public.text"],
                    isTargeted: $droppedOnOther,
                    perform: dropOnOther)
    }
    
    private func dropOnOther(_ items: [NSItemProvider], _ at: CGPoint) -> Bool {
        if let item = items.first {
            _ = item.loadObject(ofClass: String.self) { draggedId, _ in
                if let draggedId = draggedId {
                    DispatchQueue.main.async {
                        ///Convey the dragged member back to MoveToHouseholdView
                        memberId = draggedId
                        ///Now check the user dragging an other
                        let member = document.member(byId: memberId)
                        let oldHousehold = document.household(byId: member.household)
                        switch oldHousehold.statusOf(member: memberId) {
                        case .other:
                            NSLog("Dropped \(memberId) on other")
                            targetHousehold = household
                            moveToHouseholdState = .moveToExistingOther
                        default:
                            NSLog("Dropped a head or spouse \(memberId) on other")
                            targetHousehold = household
                            moveToHouseholdState = .moveToExistingDubious
                        }
                        showingSheet = true
                    }
                }
            }
        }
        return true
    }
}

struct MoveToHouseholdTarget_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdTarget(
            household: mockHousehold1,
            memberId: .constant(mockMember1.id),
            targetHousehold: .constant(mockHousehold1),
            moveToHouseholdState: .constant(MoveToHouseholdState.moveToExistingOther),
            showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewLayout(.fixed(width: 896, height: 414))
    }
}
