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
    @ObservedObject var document = PeriMeleonDocument.shared
    @Binding var accumulator: FamilyJoinAccumulator
    @State private var isEditing = false //not used in FamilyJoin
    @State private var changeCount = 0

    var body: some View {
        MemberEditView(
            member: accumulator.head,
            memberEditDelegate: FamilyJoinEditDelegate(accumulator: $accumulator),
            memberCancelDelegate: FamilyJoinCancelDelegate(accumulator: $accumulator),
            isEditing: $isEditing,
            changeCount: $changeCount)
    }
}

/**
 Delegate implementation used only by this View.
 */
fileprivate class FamilyJoinEditDelegate: MemberEditDelegate {
    @ObservedObject var document = PeriMeleonDocument.shared
    @Environment(\.undoManager) var undoManager
    var accumulator: Binding<FamilyJoinAccumulator>
    
    init(accumulator: Binding<FamilyJoinAccumulator>) {
        self.accumulator = accumulator
    }
    
    func store(member: Member) {
        NSLog("FJED onDis: val is \(member.fullName())")
        var newHousehold = NormalizedHousehold()
        newHousehold.head = member.id
        var memberInHousehold = member
        memberInHousehold.household = newHousehold.id
        document.add(member: memberInHousehold , undoManager: undoManager)
        document.add(household: newHousehold , undoManager: undoManager)
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
