//
//  MemberMarriesMemberAccumulator.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI
import PMDataTypes

struct MemberMarriesMemberAccumulator {
    var phase: MemberMarriesMemberPhase = .entry
}

enum MemberMarriesMemberPhase {
    case entry
    case verification
    case reset
}
