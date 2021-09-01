//
//  MemberMarriesMember.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI

struct MemberMarriesMember: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var linkSelection: WorkflowLink?
    @State private var accumulator = MemberMarriesMemberAccumulator()

    var body: some View {
        Group {
            switch accumulator.phase {
            case .entry:
                MemberMarriesEntryView(accumulator: $accumulator,
                                               linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .verification:
                MemberMarriesVerificationView(accumulator: $accumulator,
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
