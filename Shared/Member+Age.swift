//
//  Member+Age.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/22/20.
//

import Foundation
import PMDataTypes

extension Member {
    func age(asOf: Date) -> Int {
        guard let dob = self.dateOfBirth else { return 0 }
        if asOf < dob { return 0 }
        return Calendar.current.dateComponents([.year], from: dob, to: asOf).year!
    }
}
