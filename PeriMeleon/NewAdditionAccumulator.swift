//
//  NewAdditionAccumulator.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI
import PMDataTypes

struct NewAdditionAccumulator {
    var member = Member()
    var birthdate = Date() //need non-Optional
    var phase: NewAdditionPhase = .entry
    var comment = ""
}

enum NewAdditionPhase {
    case entry
    case verification
    case reset
}
