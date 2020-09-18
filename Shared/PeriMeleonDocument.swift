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

extension UTType {
    static let periMeleonRollsDocument = UTType(exportedAs: "com.tyndalesoft.PeriMeleon.rolls")
}

struct PeriMeleonDocument: FileDocument {
    enum State {
        case noKey
        case cannotRead
        case cannotDecrypt(errorDescription: String)
        case cannotDecode(errorDescription: String)
        case normal
    }
    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    static var writableContentTypes: [UTType] { [.periMeleonRollsDocument] }

    var households = [Household]()
    var activeHouseholds: [Household] {
        get {  households.filter { $0.head.status.isActive() }  }
    }
    var members: [Member] {
        get {
            let unsortedMembers = pullMembers(from: households)
            return unsortedMembers.sorted{ $0.fullName() < $1.fullName() }
        }
    }
    var activeMembers: [Member] { members.filter{ $0.status.isActive()} }
    private var internalState: State = .normal
    var state: State { get { internalState }}
    private var key = makeKey()

    init() {
        self.households = [Household]()
    }

    init(configuration: ReadConfiguration) throws {
        guard let decryptionKey = key else {
            NSLog("no key")
            internalState = .noKey
            households = [Household]()
            return
        }
        guard let encryptedContent = configuration.file.regularFileContents
        else {
            internalState = .cannotRead
            households = [Household]()
            NSLog("corrupt file")
            return
        }
        let decryptedContent: Data
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedContent)
            decryptedContent = try ChaChaPoly.open(sealedBox, using: decryptionKey)
        } catch {
            NSLog("cannot decrypt: \(error.localizedDescription)")
            internalState = .cannotDecrypt(errorDescription: error.localizedDescription)
            households = [Household]()
            return
        }
        do {
            let unsortedHouseholds = try jsonDecoder.decode([Household].self, from: decryptedContent)
            households = unsortedHouseholds.sorted {
                $0.head.fullName() < $1.head.fullName()
            }
            NSLog("read \(self.households.count) households from init config")
        } catch {
            let err = error as! DecodingError
            NSLog("cannot decode \(err)")
            internalState = .cannotDecode(errorDescription: "decode error \(err)")
            return
        }
    }
    
    enum WriteError: Error {
        case noKey
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let encryptionKey = key else {
            throw WriteError.noKey
        }
        let unencryptedData = try jsonEncoder.encode(self.households)
        let encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
        NSLog("writing \(encryptedData.count) bytes")
        return .init(regularFileWithContents: encryptedData)
    }
    
    private func pullMembers(from households: [Household]) -> [Member] {
        var members = [Member]()
        households.forEach { household in
            members.append(household.head)
            if let spouse = household.spouse {
                members.append(spouse)
            }
            members.append(contentsOf: household.others)
        }
        return members
    }
}

fileprivate func makeKey() -> SymmetricKey? {
    let nullSalt = Data()
    #warning("hide the password!")
    if let keyData = pbkdf2(hash: CCPBKDFAlgorithm(kCCPBKDF2),
                          password: "1234",
                          salt: nullSalt,
                          keyByteCount: 32, //256 bits
                          rounds: 8) {
        return SymmetricKey(data: keyData)
    } else { return nil }
}
