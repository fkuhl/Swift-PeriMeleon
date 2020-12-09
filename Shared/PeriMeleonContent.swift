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

let passwordAccount = "com.tyndalesoft.PeriMeleon"

struct PeriMeleonContent {
    enum State: Equatable {
        case noKey
        case cannotRead(errorDescription: String)
        case cannotDecrypt
        case cannotDecode(errorDescription: String)
        case passwordEntriesDoNotMatch(forNewFile: Bool)
        case nowWhat(errorDescription: String)
        case newFile
        case normal
    }

    // MARK: - Data
    
    var householdsById = [Id : NormalizedHousehold]() {
        didSet {
            dataCouldHaveChanged = true
            NSLog("households changed")
        }
    }
    var membersById = [Id : Member]() {
        didSet {
            dataCouldHaveChanged = true
            NSLog("members changed")
        }
    }
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
    private var internalState: State = .normal
    var state: State { get { internalState }}
    private var key: SymmetricKey? = nil
    private var encryptedData: Data
    private var dataCouldHaveChanged = false
    
    // MARK: - initializers

    /**
     This initializer is called when user makes new document.
     Then the regular initializer is called, with no intervening Views being made.
     */
    init() {
        NSLog("PeriMeleonContent init no data")
        encryptedData = Data()
        internalState = .newFile
    }
    
    init(data: Data?) {
        guard let readData = data else {
            encryptedData = Data()
            internalState = .cannotRead(errorDescription: "corrupt file")
            NSLog("corrupt file")
            return
        }
        if readData.count == 0 {
            //We have a new document.
            NSLog("PeriMeleonContent init data empty")
            encryptedData = Data()
            internalState = .newFile
            return
        }
        NSLog("PeriMeleonContent init \(data?.count ?? 0) bytes")
        encryptedData = readData
        do {
            if let decryptionKey: SymmetricKey = try GenericPasswordStore().readKey(account: passwordAccount) {
                decryptAndDecode(key: decryptionKey)
            } else {
                NSLog("no key")
                internalState = .noKey
            }
        } catch {
            NSLog("err reading keychain, \(error.localizedDescription)")
            internalState = .noKey
        }
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
            internalState = .passwordEntriesDoNotMatch(forNewFile: false)
            return
        }
        key = makeKey(password: firstAttempt)
        if let decryptionKey = key {
            decryptAndDecode(key: decryptionKey)
            do {
                try GenericPasswordStore().deleteKey(account: passwordAccount)
                try GenericPasswordStore().storeKey(decryptionKey, account: passwordAccount)
            } catch {
                NSLog("err storing key \(error.localizedDescription)")
                internalState = .nowWhat(errorDescription: "err storing key \(error.localizedDescription)")
            }
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
        case illegalState(state: State)
        case noKey
    }

    func encrypt() throws -> Data {
        guard internalState == .normal || internalState == .newFile else {
            NSLog("write attempted in state \(internalState)")
            throw WriteError.illegalState(state: internalState)
        }
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
    
    //MARK: - New database
    
    mutating func addPasswordToNewFile(firstAttempt: String, secondAttempt: String) {
        guard firstAttempt == secondAttempt else {
            self.internalState = .passwordEntriesDoNotMatch(forNewFile: true)
            return
        }
        initializeNewDB()
        key = makeKey(password: firstAttempt)
        if let encryptionKey = key {
            do {
                let unencryptedData = try jsonEncoder.encode(denormalize())
                encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
                NSLog("writing \(encryptedData.count) bytes")
                try GenericPasswordStore().deleteKey(account: passwordAccount)
                try GenericPasswordStore().storeKey(encryptionKey, account: passwordAccount)
                dataCouldHaveChanged = false
                internalState = .normal
            } catch {
                internalState = .nowWhat(errorDescription: "Error on encrypting new data: \( error.localizedDescription)")
            }
        } else {
            internalState = .noKey
        }
    }

    private mutating func initializeNewDB() {
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
