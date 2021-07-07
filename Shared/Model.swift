//
//  Model.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 7/5/21.
//

import SwiftUI
import PMDataTypes

final class Model: ObservableObject {
    /**
     For the shared ObservableObject rather than EnvironmentObjst, see:
     https://betterprogramming.pub/the-best-way-to-use-environment-objects-in-swiftui-d9a88b1e253f
     Yeah, var not let. And initializer not private.
     */
    static var shared = Model()
    
    var document: Binding<PeriMeleonDocument>? = nil
    @Published var householdsById: [ID : NormalizedHousehold]
    @Published var membersById: [ID : Member]

    var households: [NormalizedHousehold] {
        var households = [NormalizedHousehold](householdsById.values)
        households.sort {
            membersById[$0.head]?.fullName() ?? "" < membersById[$1.head]?.fullName() ?? ""
        }
        return households
    }
    var activeHouseholds: [NormalizedHousehold] {
        households.filter { membersById[$0.head]?.isActive() ?? false }
    }
    var members: [Member] {
        var members = [Member](membersById.values)
        members.sort{ $0.fullName() < $1.fullName() }
        return members
    }
    var activeMembers: [Member] {
        members.filter{ $0.isActive() }
    }
    
    //MARK: - Get data
    

    init() {
        self.householdsById = [ID : NormalizedHousehold]()
        self.membersById = [ID : Member]()
        initializeNewDB()
    }
    
    init(householdsById: [ID : NormalizedHousehold],
         membersById: [ID : Member]) {
        self.householdsById = householdsById
        self.membersById = membersById
    }

    private func initializeNewDB() {
        let mansionInTheSkyTempId = UUID().uuidString
        var goodShepherd = Member()
        goodShepherd.familyName = "Shepherd"
        goodShepherd.givenName = "Good"
        goodShepherd.placeOfBirth = "Bethlehem"
        goodShepherd.status = MemberStatus.PASTOR  // not counted against communicants
        goodShepherd.resident = false  // not counted against residents
        goodShepherd.exDirectory = true  // not included in directory
        goodShepherd.household = mansionInTheSkyTempId
        
        var mansionInTheSky = NormalizedHousehold()
        goodShepherd.household = mansionInTheSky.id
        mansionInTheSky.head = goodShepherd.id
        mansionInTheSky.id = mansionInTheSkyTempId
        membersById[goodShepherd.id] = goodShepherd
        householdsById[mansionInTheSky.id] = mansionInTheSky
    }

    //MARK: - Get data
    
    func household(byId: ID) -> NormalizedHousehold {
        householdsById[byId] ?? NormalizedHousehold()
    }
    
    func member(byId: ID) -> Member {
        membersById[byId] ?? Member()
    }
    
    func nameOf(household: NormalizedHousehold) -> String {
        member(byId: household.head).fullName()
    }
    
    func nameOf(household: ID) -> String {
        if let hh = householdsById[household] {
            return nameOf(household: hh)
        } else { return "[none]" }
    }
    
    func nameOf(member: ID) -> String {
        if let mm = membersById[member] {
            return mm.fullName()
        } else { return "[none]" }
    }

    func parentList(mustBeActive: Bool, sex: Sex) -> [Member] {
        var matches = [Member](membersById.values.filter { member in
            return member.sex == sex && !(mustBeActive && !member.isActive())
        })
        matches.sort { $0.fullName() < $1.fullName() }
        return matches
    }
    
    func filterMembers(_ isIncluded: (Member) throws -> Bool) -> [Member] {
        do {
            var results = try membersById.values.filter(isIncluded)
            results.sort { $0.fullName() < $1.fullName() }
            return results
        } catch {
            return [Member]()
        }
    }
    

    //MARK: - Update data
    
    
    func update(household: NormalizedHousehold) {
        householdsById[household.id] = household
        NSLog("households changed")
        document?.wrappedValue.encodeAndEncrypt()
    }

    func add(household: NormalizedHousehold) {
        householdsById[household.id] = household
        NSLog("households added to")
        document?.wrappedValue.encodeAndEncrypt()
    }
    
    func update(member: Member) {
        membersById[member.id] = member
        NSLog("members changed")
        document?.wrappedValue.encodeAndEncrypt()
    }
    
    func add(member: Member) {
        membersById[member.id] = member
        NSLog("members added to")
        document?.wrappedValue.encodeAndEncrypt()
    }
}
