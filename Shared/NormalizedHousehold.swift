//
//  NormalizedHousehold.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/17/20.
//

import Foundation
import PMDataTypes

/**
 A NormalizedHousehold is like a Household but Member data is not embedded, as it is in a Household structure.
 Instead a NormalizedHousehold stores an Id string that indexes into the membersById dictionary
 of PeriMeleonContent.
 */
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
