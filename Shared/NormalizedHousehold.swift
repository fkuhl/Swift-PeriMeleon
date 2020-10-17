//
//  NormalizedHousehold.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/17/20.
//

import Foundation
import PMDataTypes


struct NormalizedHousehold {
    var id: Id
    var head: Id = ""
    var spouse: Id? = nil
    var others = [Id]()
    var address: Address? = nil
    
    public init() {
        self.id = UUID().uuidString
    }
}
