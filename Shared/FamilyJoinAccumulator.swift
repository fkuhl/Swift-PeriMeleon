//
//  FamilyAccumulator.swift
//  PMClient
//
//  Created by Frederick Kuhl on 3/21/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes
/**
 Accumulate the data needed to add a family to the DB as user steps through the various screens.
 */

struct FamilyJoinAccumulator {
    
    var phase: FamilyJoinPhase = .transaction
    var dateReceived = Date()
    var receptionType: ReceptionType = .TRANSFER
    var churchFrom = ""
    var authority = ""
    var comment = ""
    var head: Member = Member()
    var receptionTransaction = PMDataTypes.Transaction()
    var addedHousehold = NormalizedHousehold()    
}

enum FamilyJoinPhase {
    case transaction
    case head
    case household
    case reset
}

enum ReceptionType: String, CaseIterable {
    case PROFESSION
    case AFFIRMATION
    case TRANSFER
}
