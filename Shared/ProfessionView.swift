//
//  ProfessionView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI

struct ProfessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var linkSelection: WorkflowLink?
    @State private var accumulator = ProfessionAccumulator()
    
    var body: some View {
        Group {
            switch accumulator.phase {
            case .entry:
                ProfessionEntryView(accumulator: $accumulator,
                                    linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .verification:
                ProfessionVerificationView(accumulator: $accumulator,
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
        .navigationBarBackButtonHidden(true)    }
}
