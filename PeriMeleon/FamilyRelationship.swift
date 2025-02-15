//
//  FamilyRelationship.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/30/21.
//

import Foundation
import PMDataTypes

enum FamilyRelationship {
    case head
    case spouse
    case other
}

struct HouseholdMembership: Hashable {
    let household: ID
    let relationship: FamilyRelationship
}
