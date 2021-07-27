//
//  FamilyDismissedAccumulator.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/27/21.
//

import SwiftUI
import PMDataTypes

struct FamilyDismissedAccumulator {
    var householdId: ID = ""
    var phase: FamilyDismissedPhase = .transaction
    var dateDismissed = Date()
    var dismissalIsPending = true
    var churchFrom = ""
    var authority = ""
    var comment = ""
    var dismissalTransaction = PMDataTypes.Transaction()
}

enum FamilyDismissedPhase {
    case transaction
    case verification
    case reset
}
