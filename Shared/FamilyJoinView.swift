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
    @Binding var linkSelection: String?
    @State private var accumulator = FamilyAccumulator()

    var body: some View {
        VStack {
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
                Text("") //EmptyView won't take a nav bar title!
                    .navigationBarTitle("")
            }
        }
        .debugPrint("FJV phase \(accumulator.phase)")
        //We're not using navigation in subsequent views, so no nav buttons
        .navigationBarItems(leading: EmptyView(), trailing:EmptyView())
        .navigationBarBackButtonHidden(true)
    }
}

//struct FamilyJoinView_Previews: PreviewProvider {
//    static var previews: some View {
//        FamilyJoinView()
//    }
//}
