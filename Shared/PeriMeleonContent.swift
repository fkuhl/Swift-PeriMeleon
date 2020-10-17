//
//  PeriMeleonContent.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 9/19/20.
//

import Foundation
import PMDataTypes
import CryptoKit
import CommonCrypto

struct PeriMeleonContent {
    enum State: Equatable {
        case noKey
        case cannotRead
        case cannotDecrypt
        case cannotDecode(errorDescription: String)
        case passwordEntriesDoNotMatch
        case normal
    }

    // MARK: - Data
    
    var householdsById = [Id : NormalizedHousehold]()
    var membersById = [Id : Member]()
    var households: [NormalizedHousehold] {
        var households = [NormalizedHousehold](householdsById.values)
        households.sort {
            membersById[$0.head]?.fullName() ?? "" < membersById[$1.head]?.fullName() ?? ""
        }
        return households
    }
    var activeHouseholds: [NormalizedHousehold] {
        households.filter { membersById[$0.head]?.status.isActive() ?? false }
    }
    var members: [Member] {
        var members = [Member](membersById.values)
        members.sort{ $0.fullName() < $1.fullName() }
        return members
    }
    var activeMembers: [Member] {
        members.filter{ $0.status.isActive() }
    }
    private var internalState: State = .normal
    var state: State { get { internalState }}
    #warning("hide the password!")
    private var key = makeKey(password: "1234")
    private var encryptedData: Data
    private var dataCouldHaveChanged = false
    
    // MARK: - initializers

    init() {
        NSLog("PeriMeleonContent init no data")
        self.encryptedData = Data()
        self.internalState = .normal
    }
    
    init(data: Data?) {
        NSLog("PeriMeleonContent init \(data?.count ?? 0) bytes")
        guard let readData = data else {
            self.encryptedData = Data()
            internalState = .cannotRead
            NSLog("corrupt file")
            return
        }
        encryptedData = readData
        guard let decryptionKey = key else {
            NSLog("no key")
            internalState = .noKey
            return
        }
        decryptAndDecode(key: decryptionKey)
    }
    
    //MARK: - Crypto
    
    mutating private func decryptAndDecode(key: SymmetricKey) {
        let decryptedContent: Data
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
            decryptedContent = try ChaChaPoly.open(sealedBox, using: key)
            dataCouldHaveChanged = true
            //No point in hanging on to what worked, as this whole struct gets replaced.
        } catch {
            NSLog("cannot decrypt: \(error.localizedDescription)")
            internalState = .cannotDecrypt
            householdsById = [Id : NormalizedHousehold]()
            membersById = [Id : Member]()
            return
        }
        do {
            let decodedHouseholds = try jsonDecoder.decode([Household].self, from: decryptedContent)
//            households = unsortedHouseholds.sorted {
//                $0.head.fullName() < $1.head.fullName()
//            }
            NSLog("read \(decodedHouseholds.count) households from init config")
            normalize(decodedHouseholds: decodedHouseholds)
            internalState = .normal
        } catch {
            let err = error as! DecodingError
            NSLog("cannot decode \(err)")
            internalState = .cannotDecode(errorDescription: "decode error \(err)")
            return
        }
    }
    
    mutating func tryPassword(firstAttempt: String, secondAttempt: String) {
        guard firstAttempt == secondAttempt else {
            self.internalState = .passwordEntriesDoNotMatch
            return
        }
        key = makeKey(password: firstAttempt)
        if let decryptionKey = key {
            decryptAndDecode(key: decryptionKey)
        } else {
            internalState = .noKey
        }
    }
    
    /**
     Create normalized indexes of households and members.
     - precondition: households has been decoded and set.
     */
    private mutating func normalize(decodedHouseholds: [Household]) {
        householdsById = [Id : NormalizedHousehold]()
        membersById = [Id : Member]()
        decodedHouseholds.forEach { household in
            var normalizedHousehold = NormalizedHousehold()
            normalizedHousehold.id = household.id
            membersById[household.head.id] = household.head
            normalizedHousehold.head = household.head.id
            if let spouse = household.spouse {
                membersById[spouse.id] = spouse
                normalizedHousehold.spouse = spouse.id
            } else {
                normalizedHousehold.spouse = nil
            }
            var normalizedOthers = [Id]()
            household.others.forEach { other in
                membersById[other.id] = other
                normalizedOthers.append(other.id)
            }
            normalizedHousehold.others = normalizedOthers
            normalizedHousehold.address = household.address
            householdsById[household.id] = normalizedHousehold
        }
    }
    
    /**
     Recreate normalized array of Households for encoding from denormalized indexes.
     */
    private func denormalize() -> [Household] {
        var denormalizedArray = [Household]()
        householdsById.values.forEach { household in
            var denormalized = Household()
            denormalized.id = household.id
            if let head = membersById[household.head] {
                denormalized.head = head
            }
            if let spouseId = household.spouse {
                if let spouse = membersById[spouseId] {
                    denormalized.spouse = spouse
                }
            } else { denormalized.spouse = nil }
            denormalized.others = household.others.compactMap { membersById[$0] }
            denormalized.address = household.address
            denormalizedArray.append(denormalized)
        }
        return denormalizedArray
    }

    enum WriteError: Error {
        case noKey
    }

    func encrypt() throws -> Data {
        if !dataCouldHaveChanged {
            NSLog("data could not have changed")
            return encryptedData
        }
        guard let encryptionKey = key else {
            throw WriteError.noKey
        }
        let unencryptedData = try jsonEncoder.encode(denormalize())
        let encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
        NSLog("writing \(encryptedData.count) bytes")
        return encryptedData
    }
    
    //MARK: - Get data
    
    func household(byId: Id) -> NormalizedHousehold {
        householdsById[byId] ?? NormalizedHousehold()
    }
    
    func member(byId: Id) -> Member {
        membersById[byId] ?? Member()
    }
    
    func nameOf(household: NormalizedHousehold) -> String {
        member(byId: household.head).fullName()
    }
    
    func nameOf(household: Id) -> String {
        if let hh = householdsById[household] {
            return nameOf(household: hh)
        } else { return "[none]" }
    }
    
    func nameOf(member: Id) -> String {
        if let mm = membersById[member] {
            return mm.fullName()
        } else { return "[none]" }
    }

    func parentList(mustBeActive: Bool, sex: Sex) -> [Member] {
        var matches = [Member](membersById.values.filter { member in
            return member.sex == sex && !(mustBeActive && !member.status.isActive())
        })
        matches.sort { $0.fullName() < $1.fullName() }
        return matches
    }
    
    func filterMembers(_ isIncluded: (Member) throws -> Bool) -> [Member] {
        do {
            return try membersById.values.filter(isIncluded)
        } catch {
            return [Member]()
        }
    }

    //MARK: - Update data
    
    mutating func update(household: NormalizedHousehold) {
        householdsById[household.id] = household
    }

    mutating func add(household: NormalizedHousehold) {
        householdsById[household.id] = household
    }
    
    mutating func update(member: Member) {
        membersById[member.id] = member
    }
    
    mutating func add(member: Member) {
        membersById[member.id] = member
    }
}

fileprivate func makeKey(password: String) -> SymmetricKey? {
    let nullSalt = Data()
    if let keyData = pbkdf2(hash: CCPBKDFAlgorithm(kCCPBKDF2),
                            password: password,
                            salt: nullSalt,
                            keyByteCount: 32, //256 bits
                            rounds: 8) {
        return SymmetricKey(data: keyData)
    } else { return nil }
}
