//
//  MoveToHouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/22/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct MoveToHouseholdView: View {
    @Binding var document: PeriMeleonDocument
    @EnvironmentObject var accumulator: MoveToHouseholdAccumulator
    
    var body: some View {
        Form {
            Text("Coming soon!")
        }
        .navigationBarTitle("Member Moves To Different Household")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MoveToHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdView(document: mockDocument)
    }
}
