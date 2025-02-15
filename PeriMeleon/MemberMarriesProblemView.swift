//
//  MemberMarriesProblemView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 9/2/21.
//

import SwiftUI
import PMDataTypes

struct MemberMarriesProblemView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: MemberMarriesMemberAccumulator
    @Binding var linkSelection: WorkflowLink?

    var body: some View {
        Form {
            Section(header: Text("Marriage Between Two Members - Problem").font(.headline)) {
                Text("There is a problem with marital status and position in household.")
                Text("This applies to:")
                HStack {
                    switch accumulator.phase {
                    case .problem(let groomProblem, let brideProblem):
                        if groomProblem {
                            Label("groom", systemImage: "checkmark.square")
                        } else {
                            Label("groom", systemImage: "square")
                        }
                        Spacer()
                        if brideProblem {
                            Label("bride", systemImage: "checkmark.square")
                        } else {
                            Label("bride", systemImage: "square")
                        }
                        Spacer()
                    default:
                        Text("whoops")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        //.navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Marries Member - Problem")
            }
            ToolbarItem(placement: .primaryAction) {
                dismissButton
            }
        }
    }
    
    private var dismissButton: some View {
        Button(action: {
            NSLog("MMP Dismiss")
            accumulator.phase = .reset
            linkSelection = nil //ensure WorkflowsView can go again
            
        }) {
            Text("Dismiss").font(.body)
        }
    }
}

struct MemberMarriesProblemView_Previews: PreviewProvider {
    static var previews: some View {
        MemberMarriesProblemView(
        accumulator: Binding.constant(MemberMarriesMemberAccumulator()),
        linkSelection: Binding.constant(nil))
        .environmentObject(mockDocument)
    }
}
