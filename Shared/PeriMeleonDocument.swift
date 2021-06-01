//
//  PeriMeleonDocument.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI
import UniformTypeIdentifiers
import PMDataTypes
import CryptoKit
import CommonCrypto

let passwordAccount = "com.tyndalesoft.PeriMeleonx"

extension UTType {
    static let periMeleonRollsDocument = UTType(exportedAs: "com.tyndalesoft.PeriMeleon.rolls")
}

struct PeriMeleonDocument: FileDocument {
    enum State: Equatable {
        case noKey
        case cannotRead(errorDescription: String)
        case cannotDecrypt
        case cannotDecode(d1: String, d2: String, d3: String)
        case passwordEntriesDoNotMatch
        case nowWhat(errorDescription: String)
        case newFile
        case normal
    }

    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    static var writableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    

    // MARK: - Data
    
    private var householdsById = [Id : NormalizedHousehold]()
    private var membersById = [Id : Member]()
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
    var state: State = .normal
    private var key: SymmetricKey? = nil
    
    /** This, it turns out, is what the framework is watching.
     encryptedData must be updated every time the document changes.
     */
    private var encryptedData: Data
    
    // MARK: - initializers

    ///On new file, framework calls empty initializer, then regular, with no views created in between.
    init() {
            //We have a new document.
            NSLog("PeriMeleonDocument init no data")
            encryptedData = Data()
            state = .newFile
            return
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if data.count == 0 {
            //We have a new document.
            NSLog("PeriMeleonDocument init data empty")
            self.encryptedData = data
            state = .newFile
            return
        }
        NSLog("PeriMeleonDocument init \(data.count) bytes")
        self.encryptedData = data
        do {
            if let decryptionKey: SymmetricKey = try GenericPasswordStore().readKey(account: passwordAccount) {
                decryptAndDecode(key: decryptionKey)
                key = decryptionKey
            } else {
                NSLog("no key")
                state = .noKey
            }
        } catch {
            NSLog("err reading keychain, \(error.localizedDescription)")
            state = .noKey
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: encryptedData)
    }
    
    //MARK: - Crypto
    
    mutating private func decryptAndDecode(key: SymmetricKey) {
        let decryptedContent: Data
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
            decryptedContent = try ChaChaPoly.open(sealedBox, using: key)
        } catch {
            NSLog("cannot decrypt: \(error.localizedDescription)")
            state = .cannotDecrypt
            householdsById = [Id : NormalizedHousehold]()
            membersById = [Id : Member]()
            return
        }
        do {
            let decodedHouseholds = try jsonDecoder.decode([Household].self,
                                                           from: decryptedContent)
            NSLog("read \(decodedHouseholds.count) households from init config")
            normalize(decodedHouseholds: decodedHouseholds)
            state = .normal
        } catch {
            let err = error as! DecodingError
            let explanation = explain(error: err)
            NSLog("cannot decode JSON: \(err)")
            state = .cannotDecode(d1: explanation.0,
                                          d2: explanation.1,
                                          d3: explanation.2)
            return
        }
    }
    
    mutating func tryPassword(firstAttempt: String) {
        key = makeKey(password: firstAttempt)
        if let decryptionKey = key {
            decryptAndDecode(key: decryptionKey)
            do {
                try GenericPasswordStore().deleteKey(account: passwordAccount)
                try GenericPasswordStore().storeKey(decryptionKey, account: passwordAccount)
            } catch {
                NSLog("err storing key \(error.localizedDescription)")
                state = .nowWhat(errorDescription: "err storing key \(error.localizedDescription)")
            }
        } else {
            state = .noKey
        }
    }
    
    enum WriteError: Error {
        case illegalState(state: State)
        case noKey
    }
    
    mutating func encrypt() throws -> Data {
        guard state == .normal || state == .newFile else {
            NSLog("write attempted in state \(state)")
            throw WriteError.illegalState(state: state)
        }
        guard let encryptionKey = key else {
            throw WriteError.noKey
        }
        let unencryptedData = try jsonEncoder.encode(denormalize())
        encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
        NSLog("storing \(encryptedData.count) bytes")
        return encryptedData
    }

    
    //MARK: - Decoding

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
    
    //MARK: - New database
    
    mutating func addPasswordToNewFile(firstAttempt: String, secondAttempt: String) {
        guard firstAttempt == secondAttempt else {
            self.state = .passwordEntriesDoNotMatch
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
                state = .normal
            } catch {
                state = .nowWhat(errorDescription: "Error on encrypting new data: \( error.localizedDescription)")
            }
        } else {
            state = .noKey
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
        NSLog("households changed")
        do {
            encryptedData = try encrypt()
        } catch {
            NSLog("error on encrypt:\(error.localizedDescription)")
        }
    }

    mutating func add(household: NormalizedHousehold) {
        householdsById[household.id] = household
        NSLog("households added to")
        do {
            encryptedData = try encrypt()
        } catch {
            NSLog("error on encrypt:\(error.localizedDescription)")
        }
    }
    
    mutating func update(member: Member) {
        membersById[member.id] = member
        NSLog("members changed")
        do {
            encryptedData = try encrypt()
        } catch {
            NSLog("error on encrypt:\(error.localizedDescription)")
        }
    }
    
    mutating func add(member: Member) {
        membersById[member.id] = member
        NSLog("members added to")
        do {
            encryptedData = try encrypt()
        } catch {
            NSLog("error on encrypt:\(error.localizedDescription)")
        }
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
