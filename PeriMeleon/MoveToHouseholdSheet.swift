//
//  MoveToHouseholdSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 1/3/22.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdSheet: View {
    @Binding var memberId: ID
    @Binding var targetHousehold: NormalizedHousehold
    @Binding var moveToHouseholdState: MoveToHouseholdState
    
    var body: some View {
        switch moveToHouseholdState {
        case .enteringData:
            Text("This should never happen!")
        case .moveToNew:
            MoveToHouseholdNewSheet(memberId: $memberId)
        case .moveToExistingOther:
            MoveToHouseholdOtherSheet(
                memberId: $memberId,
                targetHousehold: $targetHousehold)
        case .moveToExistingDubious:
            MoveToHouseholdDubiousSheet(
                memberId: $memberId,
                targetHousehold: $targetHousehold)
        }
    }
}

//struct MoveToHouseholdSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        MoveToHouseholdSheet()
//    }
//}
