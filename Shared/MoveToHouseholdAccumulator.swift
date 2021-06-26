//
//  MoveToHouseholdAccumulator.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/22/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import Foundation
import PMDataTypes

/**
 Accumulate data to move member from household to another.
 */

class MoveToHouseholdAccumulator: ObservableObject {
    @Published var member = Member()
    @Published var previousHouseholdId: ID = ""
    @Published var newHouseholdId: ID = ""
}
