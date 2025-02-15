//
//  Member+isActive.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/5/20.
//

import Foundation
import PMDataTypes

extension Member {
    func isActive() -> Bool {
        return status.isActive() && !exDirectory
    }
}
