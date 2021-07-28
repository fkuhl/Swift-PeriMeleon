//
//  NewAddition.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI

struct NewAddition: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var linkSelection: WorkflowLink?
    @State private var accumulator = NewAdditionAccumulator()
    
    var body: some View {
        Group {
            switch accumulator.phase {
            case .entry:
                NewAdditionEntryView(accumulator: $accumulator,
                                               linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .verification:
                NewAdditionVerificationView(accumulator: $accumulator,
                                                linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .reset:
                Text("")
                    .toolbar {
                        ToolbarItem(placement: .principal) { Text("") }
                    }
            }
        }
        .debugPrint("FDV phase \(accumulator.phase)")
        //We're not using navigation in subsequent views, so no nav buttons
        //Not altogether clear I need to be doing this
        .navigationBarBackButtonHidden(true)
    }
}
