//
//  MemberMarriesMember.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI
import PMDataTypes

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
            case .problem:
                MemberMarriesProblemView(accumulator: $accumulator,
                                       linkSelection: $linkSelection)
                    .transition(.move(edge: .trailing))
            case .verification:
                MemberMarriesVerificationView(accumulator: $accumulator,
                                              linkSelection: $linkSelection,
                                              combined: [ID]())
                    .transition(.move(edge: .trailing))
            case .reset:
                Text("")
                    .toolbar {
                        ToolbarItem(placement: .principal) { Text("") }
                    }
            }
        }
        .debugPrint("MMM phase \(accumulator.phase)")
    }
}
