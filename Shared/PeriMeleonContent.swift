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
    #warning("hide the password!")
    private var key = makeKey(password: "123")
    private var encryptedData: Data
    private var dataCouldHaveChanged = false

    init() {
        NSLog("PeriMeleonContent init no data")
        self.households = [Household]()
        self.encryptedData = Data()
        self.internalState = .normal
    }
    
    init(data: Data?) {
        NSLog("PeriMeleonContent init \(data?.count ?? 0) bytes")
        guard let readData = data else {
            self.households = [Household]()
            self.encryptedData = Data()
            internalState = .cannotRead
            households = [Household]()
            NSLog("corrupt file")
            return
        }
        encryptedData = readData
        guard let decryptionKey = key else {
            NSLog("no key")
            internalState = .noKey
            households = [Household]()
            return
        }
        decryptAndDecode(key: decryptionKey)
    }
    
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
            households = [Household]()
            return
        }
        do {
            let unsortedHouseholds = try jsonDecoder.decode([Household].self, from: decryptedContent)
            households = unsortedHouseholds.sorted {
                $0.head.fullName() < $1.head.fullName()
            }
            NSLog("read \(self.households.count) households from init config")
            internalState = .normal
        } catch {
            let err = error as! DecodingError
            NSLog("cannot decode \(err)")
            internalState = .cannotDecode(errorDescription: "decode error \(err)")
            return
        }
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
        let unencryptedData = try jsonEncoder.encode(self.households)
        let encryptedData = try ChaChaPoly.seal(unencryptedData, using: encryptionKey).combined
        NSLog("writing \(encryptedData.count) bytes")
        return encryptedData
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
