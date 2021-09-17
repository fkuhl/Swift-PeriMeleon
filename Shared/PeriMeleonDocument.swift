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
    

    /** householdsById gives access by household ID, whereas households is the same set of households, sorted
     by head's display name; used for presenting lists. (SortedArray keeps the list sorted as it changes.)
     householdsById and households must be kept consistent.
     */
    @Published var householdsById = [ID : NormalizedHousehold]()
    var households = SortedArray<NormalizedHousehold>(areInIncreasingOrder: compareHouseholds)
    var activeHouseholds: SortedArray<NormalizedHousehold> {
        //order-of-initialization bug lurking here!
        households.filter { membersById[$0.head]?.isActive() ?? false }
    }
    
    // membersById and members must be kept consistent
    @Published var membersById = [ID : Member]()
    var members = SortedArray<Member>(areInIncreasingOrder: compareMembers)
    var activeMembers: SortedArray<Member> {
        members.filter { $0.isActive() }
    }
    
    //Defaulting to .normal lets the normal UI come up while waiting for decode
    @Published var state: State = .normal
    ///A non-private published var to ensure all Views see that the data changed.
    @Published var changeCount: UInt64 = 0
    
    ///Set in roundabout way in ContentView, because on Mac the URL isn't set properly.
    @Published var fileName = "xxxxxxxxxxxxxxxxxxxxxxxx"

    /**Holds data initially read from file, till it can be decrypted. Otherwise the document's data are in
     householdsById and membersById, with snapshots as copies of them (as Model structs).
     */
    private var initialData = Data()
    
    private var undoManager: UndoManager?

    func setUndoManager(undoManager: UndoManager?) {
        self.undoManager = undoManager
    }

    private var key: SymmetricKey? = nil
    
    
    // MARK: - initializers

    ///On new file, this initializer is called, then the oter with zero data.
    init() {
        //We have a new document.
        NSLog("PeriMeleonDocument init no data")
        state = .newFile
        fileName = "[new]"
    }
    
    ///For mocking only
    init(model: Model) {
        fileName = "[mocked]"
        householdsById = model.h
        membersById = model.m
        members = SortedArray<Member>(unsorted: membersById.values,
                                      areInIncreasingOrder: compareMembers)
        households = SortedArray<NormalizedHousehold>(unsorted: householdsById.values,
                                                      areInIncreasingOrder: compareHouseholds)
        state = .normal
    }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if data.count == 0 {
            //We have a new document.
            NSLog("PeriMeleonDocument init data empty, file: \(fileName)")
            state = .newFile
            //fileName = configuration.fileURL?.lastPathComponent
            self.householdsById = [ID : NormalizedHousehold]()
            self.membersById = [ID : Member]()
            //Initializing the DB is deferred: see addPasswordToNewFile
            return
        }
        NSLog("PeriMeleonDocument init \(data.count) bytes from file \(fileName)")
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
    
    ///For testing: sidestep decryption
    init(data: Data,
         normalCompletion: @escaping (Model) -> Void,
         cannotDecodeCompletion: @escaping ((String,String,String)) -> Void) {
        fileName = ""
        decode(data,
               normalCompletion: normalCompletion,
               cannotDecodeCompletion: cannotDecodeCompletion)
    }
    
    
    // MARK: - ReferenceFileDocument

    func snapshot(contentType: UTType) throws -> Model {
        NSLog("snapshot \(householdsById.count) households, \(membersById.count) members")
        return Model(h: householdsById, m: membersById, sh: households, sm: members)
    }
    
    func fileWrapper(snapshot: Model, configuration: WriteConfiguration) throws -> FileWrapper {
        let encrypted = encodeAndEncrypt(model: snapshot)
        NSLog("writing \(encrypted.count) bytes")
        return FileWrapper(regularFileWithContents: encrypted)
    }

    
    //MARK: - Crypto
    
    ///The `decrypt` part of this is very fast. The `decode` part is much slower, so goes on a background thread.
    private func decryptAndDecode(_ data: Data, key: SymmetricKey) {
        let decryptedContent: Data
        do {
            NSLog("will decrypt")
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            decryptedContent = try ChaChaPoly.open(sealedBox, using: key)
        } catch {
            NSLog("cannot decrypt: \(error.localizedDescription)")
            state = .cannotDecrypt
            householdsById = [ID : NormalizedHousehold]()
            households = SortedArray<NormalizedHousehold>(areInIncreasingOrder: compareHouseholds)
            membersById = [ID : Member]()
            members = SortedArray<Member>(areInIncreasingOrder: compareMembers)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            decode(decryptedContent) { model in
                setModel(model: model)
            } cannotDecodeCompletion: { explanation in
                setCannotDecode(explanation: explanation)
            }
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
    
    ///Split out to facilitate testing: sidesteps decryption
    func decode(_ decryptedContent: Data,
                normalCompletion: @escaping (Model) -> Void,
                cannotDecodeCompletion: @escaping ((String,String,String)) -> Void) {
        do {
            NSLog("will decode")
            let decodedHouseholds = try jsonDecoder.decode([Household].self,
                                                           from: decryptedContent)
            NSLog("did decode \(decodedHouseholds.count) households from init config")
            let model = self.normalize(decodedHouseholds: decodedHouseholds)
            DispatchQueue.main.async {
                normalCompletion(model)
            }
        } catch {
            let err = error as! DecodingError
            let explanation = explain(decodingError: err)
            NSLog("cannot decode JSON: \(err)")
            DispatchQueue.main.async {
                cannotDecodeCompletion(explanation)
            }
            return
        }
    }
    
    func setModel(model: Model) {
        membersById = model.m
        householdsById = model.h
        households = model.sh
        members = model.sm
        state = .normal
        changeCount += 1
        NSLog("sorted")
    }
    
    func setCannotDecode(explanation: (String,String,String)) {
        state = .cannotDecode(basicError: explanation.0,
                              codingPath: explanation.1,
                              underlyingError: explanation.2)
    }

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
            normalizedHousehold.name = household.head.displayName()
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
        let sh = SortedArray<NormalizedHousehold>(unsorted: householdsById.values,
                                                  areInIncreasingOrder: compareHouseholds)
        let sm = SortedArray<Member>(unsorted: membersById.values,
                                     areInIncreasingOrder: compareMembers)
        return Model(h: householdsById,
                     m: membersById,
                     sh: sh,
                     sm: sm)
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
                initializeNewDB()
            } catch {
                state = .saveError(basicError: "Error on encrypting new data",
                                   codingPath: "",
                                   underlyingError: error.localizedDescription)
            }
        } else {
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
        mansionInTheSky.name = goodShepherd.displayName()
        mansionInTheSky.id = mansionInTheSkyTempId
        add(member: goodShepherd) //Set the undo! (Hope the mgr is set!)
        add(household: mansionInTheSky)
    }

    //MARK: - Get data
    
    func household(byId: ID) -> NormalizedHousehold {
        householdsById[byId] ?? NormalizedHousehold()
    }
    
    func member(byId: ID) -> Member {
        membersById[byId] ?? Member()
    }
    
    func nameOf(household: NormalizedHousehold) -> String {
        nameOf(member: household.head)
    }
    
    func nameOf(household: ID) -> String {
        if let hh = householdsById[household] {
            return nameOf(household: hh)
        } else { return "[none]" }
    }
    
    func nameOf(member: ID) -> String {
        if let mm = membersById[member] {
            return mm.displayName()
        } else { return "[none]" }
    }

    func parentList(mustBeActive: Bool, sex: Sex) -> [Member] {
        var matches = [Member](membersById.values.filter { member in
            return member.sex == sex && !(mustBeActive && !member.isActive())
        })
        matches.sort { $0.fullName() < $1.fullName() }
        return matches
    }
    
    func filterMembers(_ isIncluded: MemberFilter) -> [Member] {
        var results = membersById.values.filter(isIncluded)
        results.sort { $0.fullName() < $1.fullName() }
        return results
    }
    
    func checkForRemovals(member: ID) -> (ready: [ID], suspect: [ID]) {
        var suspect = [ID]()
        var ready = [ID]()
        for household in households {
            if member == household.head {
                if containsOnlyHead(household: household.id) {
                    //member ready for removal if no other household members
                    ready.append(household.id)
                } else {
                    //member is head of non-empty household: suspect
                    suspect.append(household.id)
                }
            } else if member == household.spouse || household.others.contains(member) {
                //member belongs to housegold, but not as head
                ready.append(household.id)
            }
        }
        return (ready: ready, suspect: suspect)
    }
    
    func containsOnlyHead(household: ID) -> Bool {
        //If no household for this id, will return true
        let nh = self.household(byId: household)
        return nh.spouse == nil && nh.others.count == 0
    }
    

    //MARK: - Update data
    
    func update(household: NormalizedHousehold) {
        guard let oldValue = householdsById[household.id],
              let oldIndex = households.firstIndex(of: oldValue) else {
            householdsById[household.id] = household
            households.insert(household)
            NSLog("households changed (really, added to), undo is \(String(describing: undoManager))")
            changeCount += 1
            undoManager?.registerUndo(withTarget: self) { doc in
                doc.remove(household: household)
            }
            return
        }
        householdsById[household.id] = household
        households.remove(at: oldIndex)
        households.insert(household)
        NSLog("households changed, undo is \(String(describing: undoManager))")
        changeCount += 1
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.update(household: oldValue)
        }
    }
    
    func remove(household: NormalizedHousehold) {
        householdsById.removeValue(forKey: household.id)
        households.remove(household)
        changeCount += 1
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.add(household: household)
        }
    }

    func add(household: NormalizedHousehold) {
        //ensure name is stored to keep households sorted (this is fragile!)
        var toBeInserted = household
        toBeInserted.name = nameOf(household: toBeInserted)
        householdsById[toBeInserted.id] = toBeInserted
        households.insert(toBeInserted)
        NSLog("households added to, undo is \(String(describing: undoManager))")
        changeCount += 1
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.remove(household: toBeInserted)
        }
    }
    
    func update(member: Member) {
        guard let oldValue = membersById[member.id], let oldIndex = members.firstIndex(of: oldValue) else {
            membersById[member.id] = member
            members.insert(member)
            NSLog("members changed (really, added to), undo is \(String(describing: undoManager))")
            changeCount += 1
            undoManager?.registerUndo(withTarget: self) { doc in
                doc.remove(member: member)
            }
            return
        }
        membersById[member.id] = member
        members.remove(at: oldIndex)
        members.insert(member)
        NSLog("members changed, undo is \(String(describing: undoManager))")
        changeCount += 1
        self.undoManager?.registerUndo(withTarget: self) { doc in
            doc.update(member: oldValue)
        }
    }
    
    func remove(member: Member) {
        membersById.removeValue(forKey: member.id)
        members.remove(member)
        changeCount += 1
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.add(member: member)
        }
    }
    
    func add(member: Member) {
        membersById[member.id] = member
        members.insert(member)
        changeCount += 1
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


//MARK: - Comparators & typealias

func compareMembers(a: Member, b: Member) -> Bool {
    a.displayName() < b.displayName()
}

func compareHouseholds(a: NormalizedHousehold, b: NormalizedHousehold) -> Bool {
    a.name ?? "" < b.name ?? ""
}

typealias MemberFilter = (Member) -> Bool
