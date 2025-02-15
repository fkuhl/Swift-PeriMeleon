//
//  FamilyJoinView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct FamilyJoinView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var linkSelection: WorkflowLink?
    @State private var accumulator = FamilyJoinAccumulator()

    var body: some View {
        Group {
            switch accumulator.phase {
            case .transaction:
                FamilyJoinTransactionPhaseView(accumulator: $accumulator, linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .head:
                FamilyJoinHeadPhaseView(accumulator: $accumulator)
                    .transition(.move(edge: .trailing))
            case .household:
                FamilyJoinHouseholdPhaseView(accumulator: $accumulator,
                                             linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .reset:
                Text("")
                    .toolbar {
                        ToolbarItem(placement: .principal) { Text("") }
                    }
            }
        }
        .debugPrint("FJV phase \(accumulator.phase)")
    }
}
