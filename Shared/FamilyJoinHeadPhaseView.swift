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
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: FamilyJoinAccumulator
    @State private var isEditing = false //not used in FamilyJoin
    @State private var changeCount = 0

    var body: some View {
        MemberEditView(
            member: accumulator.head,
            memberEditDelegate: FamilyJoinEditDelegate(document: document,
                accumulator: $accumulator),
            memberCancelDelegate: FamilyJoinCancelDelegate(accumulator: $accumulator),
            isEditing: $isEditing,
            changeCount: $changeCount)
    }
}

/**
 Delegate implementation used only by this View.
 */
fileprivate class FamilyJoinEditDelegate: MemberEditDelegate {
    private var document: PeriMeleonDocument
    var accumulator: Binding<FamilyJoinAccumulator>
    
    init(document: PeriMeleonDocument, accumulator: Binding<FamilyJoinAccumulator>) {
        self.document = document
        self.accumulator = accumulator
    }
    
    func store(member: Member) {
        NSLog("FJED onDis: val is \(member.fullName())")
        var newHousehold = NormalizedHousehold()
        newHousehold.head = member.id
        var memberInHousehold = member
        memberInHousehold.household = newHousehold.id
        document.add(member: memberInHousehold)
        document.add(household: newHousehold)
        accumulator.wrappedValue.head = memberInHousehold
        accumulator.wrappedValue.addedHousehold = newHousehold
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            accumulator.wrappedValue.phase = .household
        }
    }
}

fileprivate class FamilyJoinCancelDelegate: MemberCancelDelegate {
    var accumulator: Binding<FamilyJoinAccumulator>
    
    init(accumulator: Binding<FamilyJoinAccumulator>) {
        self.accumulator = accumulator
    }
    func cancel() {
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            accumulator.wrappedValue.phase = .transaction
        }
    }

}
