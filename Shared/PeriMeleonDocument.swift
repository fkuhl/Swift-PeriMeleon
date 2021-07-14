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
 This probably should be a ReferenceFileDocument, as its state is continually changing.
 For that to work, the document signals that it needs to be saved by doing something with an UndoManager.
 It also must provide a snapshpt (type is Data?), which is what's written to the file when the document is saved,
 so the snapshot would be the encoded and encrypted data.
 See https://medium.com/@acwrightdesign/using-referencefiledocument-in-swiftui-e54ef75a14b8
 
 But making this a ReferenceFileDocument is likely a premature optimization, especially on the morning of WWDC, in which
 many things may change. [Narrator: No changes were announced at WWDC 2021.]
 */

struct PeriMeleonDocument: FileDocument {
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
        NSLog("wrapping \(encryptedData.count) bytes")
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
            //The changing singleton!!!
            Model.shared = Model(householdsById: [ID : NormalizedHousehold](),
                          membersById: [ID : Member]())
            return
        }
        do {
            let decodedHouseholds = try jsonDecoder.decode([Household].self,
                                                           from: decryptedContent)
            NSLog("read \(decodedHouseholds.count) households from init config")
            let (householdsById, membersById) = normalize(decodedHouseholds: decodedHouseholds)
            //The changing singleton!!!
            Model.shared = Model(householdsById: householdsById, membersById: membersById)
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
    
    mutating func tryPassword(firstAttempt: String) {
        key = makeKey(password: firstAttempt)
        if let decryptionKey = key {
            decryptAndDecode(key: decryptionKey)
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
    
    mutating func encodeAndEncrypt() {
        guard state == .normal || state == .newFile else {
            NSLog("write attempted in state \(state)")
            state = .saveError(basicError: "write attempted in state \(state)",
                               codingPath: "",
                               underlyingError: "")
            return
        }
        guard let encryptionKey = key else {
            state = .saveError(basicError: "key inexplicably absent",
                               codingPath: "",
                               underlyingError: "")
            return
        }
        do {
            let unencryptedData = try jsonEncoder.encode(denormalize())
            encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
        } catch let error where error is EncodingError {
            let encodingError = error as! EncodingError
            let explanation = explain(encodingError: encodingError)
            state = .saveError(basicError: explanation.0,
                               codingPath: explanation.1,
                               underlyingError: explanation.2)
        } catch {
            state = .saveError(basicError: error.localizedDescription,
                               codingPath: "",
                               underlyingError: "")
        }
        NSLog("storing \(encryptedData.count) bytes")
    }

    
    //MARK: - Decoding

    /**
     Create normalized indexes of households and members.
     - precondition: households has been decoded and set.
     */
    private func normalize(decodedHouseholds: [Household]) ->
        ([ID : NormalizedHousehold], [ID : Member]) {
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
        return (householdsById, membersById)
    }
    
    /**
     Recreate normalized array of Households for encoding from denormalized indexes.
     */
    private func denormalize() -> [Household] {
        var denormalizedArray = [Household]()
        Model.shared.householdsById.values.forEach { household in
            var denormalized = Household()
            denormalized.id = household.id
            if let head = Model.shared.membersById[household.head] {
                denormalized.head = head
            }
            if let spouseId = household.spouse {
                if let spouse = Model.shared.membersById[spouseId] {
                    denormalized.spouse = spouse
                }
            } else { denormalized.spouse = nil }
            denormalized.others = household.others.compactMap {
                Model.shared.membersById[$0]
            }
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
                state = .saveError(basicError: "Error on encrypting new data",
                                   codingPath: "",
                                   underlyingError: error.localizedDescription)
            }
        } else {
            state = .noKey
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
