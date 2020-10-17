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
    @EnvironmentObject var accumulator: FamilyAccumulator
    @Environment(\.presentationMode) var presentationMode
    @Binding var linkSelection: String?

    var body: some View {
        VStack {
            //If SwiftUI supported a switch here, that would be the right thing to use.
            if accumulator.phase == .transaction {
                FamilyJoinTransactionPhaseView()
            } else if accumulator.phase == .head {
                FamilyJoinHeadPhaseView(document: $document)
            } else if accumulator.phase == .household {
                FamilyJoinHouseholdPhaseView(document: $document)
            } else if accumulator.phase == .reset {
                Text("reset phase").onAppear() {
                    NSLog("FJV in phase reset")
                    accumulator.reset()
                    linkSelection = nil
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                Text("Oops!")
            }
        }
        .debugPrint("FJV phase \(accumulator.phase)")
        //We're not using navigation in subsequent views, so no nav buttons
        .navigationBarItems(leading: EmptyView(), trailing:EmptyView())
    }
}

//struct FamilyJoinView_Previews: PreviewProvider {
//    static var previews: some View {
//        FamilyJoinView()
//    }
//}
