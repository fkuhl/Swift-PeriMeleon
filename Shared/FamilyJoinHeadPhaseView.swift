//
//  PhaseOneView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/5/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct FamilyJoinHeadPhaseView: View {
    @Binding var document: PeriMeleonDocument
    @Binding var accumulator: FamilyAccumulator
    @State private var isEditing = false //not used in FamilyJoin

    var body: some View {
        MemberEditView(
            document: $document,
            member: accumulator.head,
            memberEditDelegate: FamilyJoinEditDelegate(document: $document,
                                                       accumulator: $accumulator),
            memberCancelDelegate: FamilyJoinCancelDelegate(accumulator: $accumulator),
            isEditing: $isEditing)
    }
}

/**
 Delegate implementation used only by this View.
 */
class FamilyJoinEditDelegate: MemberEditDelegate {
    var document: Binding<PeriMeleonDocument>
    var accumulator: Binding<FamilyAccumulator>
    
    init(document: Binding<PeriMeleonDocument>,
         accumulator: Binding<FamilyAccumulator>) {
        self.document = document
        self.accumulator = accumulator
    }
    
    func store(member: Member) {
        NSLog("FJED onDis: val is \(member.fullName())")
        var newHousehold = NormalizedHousehold()
        newHousehold.head = member.id
        var memberInHousehold = member
        memberInHousehold.household = newHousehold.id
        document.wrappedValue.content.add(member: memberInHousehold)
        document.wrappedValue.content.add(household: newHousehold)
        accumulator.wrappedValue.head = memberInHousehold
        accumulator.wrappedValue.addedHousehold = newHousehold
        withAnimation(.easeInOut(duration: MemberView.editAnimationDuration)) {
            accumulator.wrappedValue.phase = .household
        }
    }
}

class FamilyJoinCancelDelegate: MemberCancelDelegate {
    var accumulator: Binding<FamilyAccumulator>
    
    init(accumulator: Binding<FamilyAccumulator>) {
        self.accumulator = accumulator
    }
    func cancel() {
        withAnimation(.easeInOut(duration: MemberView.editAnimationDuration)) {
            accumulator.wrappedValue.phase = .transaction
        }
    }

}

//struct PhaseOneView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhaseOneView()
//    }
//}

