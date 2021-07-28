//
//  ProfessionAccumulator.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 7/28/21.
//

import SwiftUI
import PMDataTypes

struct ProfessionAccumulator {
    var memberId: ID = ""
    var date = Date()
    var phase: ProfessionPhase = .entry
    var comment = ""
}

enum ProfessionPhase {
    case entry
    case verification
    case reset
}
