//
//  HouseholdDocument.swift
//  
//
//  Created by Frederick Kuhl on 2/27/20.
//

import Foundation

/**
 Household as represented by a MongoDB document.
 */
public struct Household: Codable {
    public var id: Id = ""
    public var head: Member = Member() //data cleaned up enough so this isn't ever nil
    public var spouse: Member? = nil
    public var others: [Member] = []
    public var address: Address? = nil //nil if address unknown
    
    public init() { }
    
    /**
     Just for mocking.
     */
    public init(id: Id,
                head: Member,
                spouse: Member? = nil,
                address: Address? = nil) {
        self.id = id
        self.head = head
        self.spouse = spouse
        self.address = address
    }
    
    public func asJSONData() -> Data  {
        return try! jsonEncoder.encode(self)
    }
}

public let householdIdFieldName = "id"

