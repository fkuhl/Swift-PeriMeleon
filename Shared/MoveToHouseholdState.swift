//
//  MoveToHouseholdState.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/28/21.
//

import Foundation

enum MoveToHouseholdState {
    case enteringData
    case moveHeadToNew
    case prospectiveOrphans
    case moveEmpties
    case moveSpouseToNew
    case moveOtherToNew
    case moveToExistingSpouse
    case moveSpouseToExisting
    case moveOtherToExisting
}
