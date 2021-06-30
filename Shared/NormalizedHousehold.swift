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
 of PeriMeleonDocument.
 */
struct NormalizedHousehold {
    var id: ID
    var head: ID = ""
    var spouse: ID? = nil
    var others = [ID]()
    var address: Address? = nil
    
    public init() {
        self.id = UUID().uuidString
    }
    
    ///For mocking
    init(
        id: ID,
        head: ID,
        spouse: ID,
        others: [ID],
        address: Address?)
    {
        self.id = id
        self.head = head
        self.spouse = spouse
        self.others = others
        self.address = address
    }
}
