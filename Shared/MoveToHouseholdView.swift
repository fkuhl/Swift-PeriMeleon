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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Moves To Different Household")
            }
        }
    }
}

struct MoveToHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdView(document: mockDocument)
    }
}
