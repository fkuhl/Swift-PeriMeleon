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

/**
 See:.
 See https://medium.com/@acwrightdesign/using-referencefiledocument-in-swiftui-e54ef75a14b8
 and
 https://developer.apple.com/documentation/swiftui/building_a_document-based_app_with_swiftui

 */

class PeriMeleonDocument: ReferenceFileDocument {
    enum State: Equatable {
        case noKey
        case cannotRead(errorDescription: String)
        case cannotDecrypt
        case cannotDecode(basicError: String, codingPath: String, underlyingError: String)
        case passwordEntriesDoNotMatch
        case newFile
        case saveError(basicError: String, codingPath: String, underlyingError: String)
        case normal
    }

    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    static var writableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    

    // MARK: - Data
    
    @Published var householdsById = [ID : NormalizedHousehold]()
    @Published var membersById = [ID : Member]()
    
    /**Holds data initially read from file, till it can be decrypted. Otherwise the document's data are in
     householdsById and membersById, with snapshots as copies of them (as Model structs).
     */
    private var initialData = Data()
    
    private var undoManager: UndoManager?

    func setUndoManager(undoManager: UndoManager?) {
        self.undoManager = undoManager
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

    var state: State = .normal
    private var key: SymmetricKey? = nil
    
    
    // MARK: - initializers

    ///On new file, framework calls empty initializer, then regular, with no views created in between.
    init() {
        //We have a new document.
        NSLog("PeriMeleonDocument init no data")
        state = .newFile
        self.householdsById = [ID : NormalizedHousehold]()
        self.membersById = [ID : Member]()
        initializeNewDB()
    }
    
    ///For mocking only
    init(model: Model) {
        householdsById = model.h
        membersById = model.m
        state = .normal
    }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if data.count == 0 {
            //We have a new document.
            NSLog("PeriMeleonDocument init data empty")
            state = .newFile
            self.householdsById = [ID : NormalizedHousehold]()
            self.membersById = [ID : Member]()
            initializeNewDB()
            return
        }
        NSLog("PeriMeleonDocument init \(data.count) bytes")
        initialData = data
        do {
            if let decryptionKey: SymmetricKey = try GenericPasswordStore().readKey(account: passwordAccount) {
                decryptAndDecode(data, key: decryptionKey)
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
    
    
    // MARK: - ReferenceFileDocument

    func snapshot(contentType: UTType) throws -> Model {
        NSLog("snapshot \(householdsById.count) households, \(membersById.count) members")
        return Model(h: householdsById, m: membersById)
    }
    
    func fileWrapper(snapshot: Model, configuration: WriteConfiguration) throws -> FileWrapper {
        let encrypted = encodeAndEncrypt(model: snapshot)
        NSLog("writing \(encrypted.count) bytes")
        return FileWrapper(regularFileWithContents: encrypted)
    }

    
    //MARK: - Crypto
    
    private func decryptAndDecode(_ data: Data, key: SymmetricKey) {
        let decryptedContent: Data
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            decryptedContent = try ChaChaPoly.open(sealedBox, using: key)
        } catch {
            NSLog("cannot decrypt: \(error.localizedDescription)")
            state = .cannotDecrypt
            householdsById = [ID : NormalizedHousehold]()
            membersById = [ID : Member]()
            return
        }
        do {
            let decodedHouseholds = try jsonDecoder.decode([Household].self,
                                                           from: decryptedContent)
            NSLog("read \(decodedHouseholds.count) households from init config")
            let model = normalize(decodedHouseholds: decodedHouseholds)
            householdsById = model.h
            membersById = model.m
            state = .normal
        } catch {
            let err = error as! DecodingError
            let explanation = explain(decodingError: err)
            NSLog("cannot decode JSON: \(err)")
            state = .cannotDecode(basicError: explanation.0,
                                  codingPath: explanation.1,
                                  underlyingError: explanation.2)
            return
        }
    }
    
    func tryPassword(firstAttempt: String) {
        key = makeKey(password: firstAttempt)
        if let decryptionKey = key {
            decryptAndDecode(initialData, key: decryptionKey)
            do {
                try GenericPasswordStore().deleteKey(account: passwordAccount)
                try GenericPasswordStore().storeKey(decryptionKey, account: passwordAccount)
            } catch {
                NSLog("err storing key \(error.localizedDescription)")
                state = .saveError(basicError: "error storing key",
                                   codingPath: "",
                                   underlyingError: error.localizedDescription)
            }
        } else {
            state = .noKey
        }
    }
    
    enum WriteError: Error {
        case illegalState(state: State)
        case noKey
    }
    
    func encodeAndEncrypt(model: Model) -> Data {
        guard state == .normal || state == .newFile else {
            NSLog("write attempted in state \(state)")
            state = .saveError(basicError: "write attempted in state \(state)",
                               codingPath: "",
                               underlyingError: "")
            return Data()
        }
        guard let encryptionKey = key else {
            state = .saveError(basicError: "key inexplicably absent",
                               codingPath: "",
                               underlyingError: "")
            return Data()
        }
        do {
            let unencryptedData = try jsonEncoder.encode(denormalize(model: model))
            let encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
            NSLog("storing \(encryptedData.count) bytes")
            return encryptedData
        } catch let error where error is EncodingError {
            let encodingError = error as! EncodingError
            let explanation = explain(encodingError: encodingError)
            state = .saveError(basicError: explanation.0,
                               codingPath: explanation.1,
                               underlyingError: explanation.2)
            return Data()
        } catch {
            state = .saveError(basicError: error.localizedDescription,
                               codingPath: "",
                               underlyingError: "")
            return Data()
        }
    }

    
    //MARK: - Decoding

    /**
     Create normalized indexes of households and members.
     - precondition: households has been decoded and set.
     */
    private func normalize(decodedHouseholds: [Household]) -> Model {
        var householdsById = [ID : NormalizedHousehold]()
        var membersById = [ID : Member]()
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
            var normalizedOthers = [ID]()
            household.others.forEach { other in
                membersById[other.id] = other
                normalizedOthers.append(other.id)
            }
            normalizedHousehold.others = normalizedOthers
            normalizedHousehold.address = household.address
            householdsById[household.id] = normalizedHousehold
        }
        return Model(h: householdsById, m: membersById)
    }
    
    /**
     Recreate normalized array of Households for encoding from denormalized indexes.
     */
    private func denormalize(model: Model) -> [Household] {
        var denormalizedArray = [Household]()
        model.h.values.forEach { household in
            var denormalized = Household()
            denormalized.id = household.id
            if let head = model.m[household.head] {
                denormalized.head = head
            }
            if let spouseId = household.spouse {
                if let spouse = model.m[spouseId] {
                    denormalized.spouse = spouse
                }
            } else { denormalized.spouse = nil }
            denormalized.others = household.others.compactMap {
                model.m[$0]
            }
            denormalized.address = household.address
            denormalizedArray.append(denormalized)
        }
        return denormalizedArray
    }
    
    //MARK: - New database
    
    func addPasswordToNewFile(firstAttempt: String, secondAttempt: String) {
        guard firstAttempt == secondAttempt else {
            self.state = .passwordEntriesDoNotMatch
            return
        }
        key = makeKey(password: firstAttempt)
        if let encryptionKey = key {
            do {
                try GenericPasswordStore().deleteKey(account: passwordAccount)
                try GenericPasswordStore().storeKey(encryptionKey, account: passwordAccount)
                state = .normal
            } catch {
                state = .saveError(basicError: "Error on encrypting new data",
                                   codingPath: "",
                                   underlyingError: error.localizedDescription)
            }
        } else {
            state = .noKey
        }
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
        guard let oldValue = householdsById[household.id] else {
            householdsById[household.id] = household
            NSLog("households changed (really, added to), undo is \(String(describing: undoManager))")
            undoManager?.registerUndo(withTarget: self) { doc in
                doc.remove(household: household)
            }
            return
        }
        householdsById[household.id] = household
        NSLog("households changed, undo is \(String(describing: undoManager))")
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.update(household: oldValue)
        }
    }
    
    ///At present this is included only to give (a possibly unneeded) symmetry to the undo
    private func remove(household: NormalizedHousehold) {
        householdsById.removeValue(forKey: household.id)
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.add(household: household)
        }
    }

    func add(household: NormalizedHousehold) {
        householdsById[household.id] = household
        NSLog("households added to, undo is \(String(describing: undoManager))")
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.remove(household: household)
        }
    }
    
    func update(member: Member) {
        guard let oldValue = membersById[member.id] else {
            membersById[member.id] = member
            NSLog("members changed (really, added to), undo is \(String(describing: undoManager))")
            undoManager?.registerUndo(withTarget: self) { doc in
                doc.remove(member: member)
            }
            return
        }
        membersById[member.id] = member
        NSLog("members changed, undo is \(String(describing: undoManager))")
        self.undoManager?.registerUndo(withTarget: self) { doc in
            doc.update(member: oldValue)
        }
    }
    
    ///At present this is included only to give (a possibly unneeded) symmetry to the undo
    private func remove(member: Member) {
        membersById.removeValue(forKey: member.id)
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.add(member: member)
        }
    }
    
    func add(member: Member) {
        membersById[member.id] = member
        NSLog("members added to, undo is \(String(describing: undoManager))")
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.remove(member: member)
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
