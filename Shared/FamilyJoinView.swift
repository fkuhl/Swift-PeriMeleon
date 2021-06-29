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
    @Binding var document: PeriMeleonDocument
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
                FamilyJoinHeadPhaseView(document: $document, accumulator: $accumulator)
                    .transition(.move(edge: .trailing))
            case .household:
                FamilyJoinHouseholdPhaseView(document: $document,
                                             accumulator: $accumulator,
                                             linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .reset:
                EmptyView()
            }
        }
        .debugPrint("FJV phase \(accumulator.phase)")
        //We're not using navigation in subsequent views, so no nav buttons
        //Not altogether clear I need to be doing this
        .toolbar { }
        .navigationBarBackButtonHidden(true)
    }
}
