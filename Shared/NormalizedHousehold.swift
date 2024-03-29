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
struct NormalizedHousehold: Identifiable {
    var id: ID
    var head: ID = ""
    /** This field supports storing NormalizedHouseholds in SortedArray.
     It is assumed that this field will be filled in anytime a NormalizedHousehold is created,
     and thereafter not changed.
     I suppose there is a potential bug if the head of a household ever changes his name
 */
    var name: String? = nil
    var spouse: ID? = nil
    var others = [ID]()
    var address: Address? = nil
    
    init() {
        self.id = UUID().uuidString
    }
    
    ///For mocking
    init(
        id: ID,
        head: ID,
        spouse: ID?,
        others: [ID],
        address: Address?)
    {
        self.id = id
        self.head = head
        self.spouse = spouse
        self.others = others
        self.address = address
        self.name = id
    }
    
    mutating func remove(other: ID) {
        let depleted = others.filter { $0 != other }
        others = depleted
    }
    
    func statusOf(member: ID) -> HouseholdStatus {
        if head == member { return .head }
        if let spouseId = spouse {
            if spouseId == member { return .spouse }
        }
        for other in others {
            if other == member { return .other }
        }
        return .notMember
    }
}

enum HouseholdStatus {
    case notMember
    case head
    case spouse
    case other
}
