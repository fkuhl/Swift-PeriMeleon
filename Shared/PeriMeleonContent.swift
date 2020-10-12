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
    
    var households = [Household]() {
        didSet {
            activeHouseholds = households.filter { $0.head.status.isActive() }
            let unsortedMembers = pullMembers()
            members = unsortedMembers.sorted{
                memberWith(relation: $0).fullName() < memberWith(relation: $1).fullName()
            }
            activeMembers = members.filter{ memberWith(relation: $0).status.isActive() }
        }
    }
    var activeHouseholds: [Household] = [Household]()
    var members = [MemberRelation]()
    var activeMembers = [MemberRelation]()
    private var internalState: State = .normal
    var state: State { get { internalState }}
    #warning("hide the password!")
    private var key = makeKey(password: "1234")
    private var encryptedData: Data
    private var dataCouldHaveChanged = false
    
    // MARK: - initializers

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
    
    //MARK: - Get data
    
    private func pullMembers() -> [MemberRelation] {
        var members = [MemberRelation]()
        households.forEach { household in
            members.append(MemberRelation(householdId: household.id, relation: .head))
            if household.spouse != nil {
                members.append(MemberRelation(householdId: household.id, relation: .spouse))
            }
            for i in 0 ..< household.others.count {
                members.append(MemberRelation(householdId: household.id, relation: .other(i)))
            }
        }
        return members
    }

    func nameOfHousehold(_ id: Id) -> String {
        if let household = households.first(where: { $0.id == id}) {
            return household.head.fullName()
        } else {
            NSLog("PMContent.nameOfHousehold no entry for id \(id)")
            return "[none]"
        }
    }
    
    func memberWith(relation: MemberRelation) -> Member {
        var value = Member()
        if let household = households.first(where: { $0.id == relation.householdId }) {
            switch relation.relation {
            case .head:
                value = household.head
            case .spouse:
                if let actualSpouse = household.spouse {
                    value = actualSpouse
                }
            case .other(let otherIndex):
                value = household.others[otherIndex]
            }
        }
        return value
    }
    
    func memberWith(id: Id) -> Member {
        var value = Member()
        
        return value
    }

    func parentList(mustBeActive: Bool, sex: Sex) -> [MemberRelation] {
        return members.filter {
            let member = memberWith(relation: $0)
            return member.sex == sex && !(mustBeActive && !member.status.isActive())
        }
    }

    //MARK: - Update data
    
    mutating func update(household: Household) {
        if let index = households.firstIndex(where: { $0.id == household.id }) {
            households[index] = household
        } else {
            NSLog("OMContents.updateHousehold no entry for id \(household.id)")
        }
    }
    
    mutating func add(household: Household) {
        households.append(household)
    }
    
    mutating func update(member: Member) {
        guard let householdIndexToEdit = households.firstIndex(where: { $0.id == member.household} ) else {
            NSLog("PMContents.updateMember houshold not found, id: \(member.household)")
            return
        }
        var householdToEdit = households[householdIndexToEdit]
        NSLog("member id \(member.id) name>: \(member.fullName())")
        NSLog("h to edit index \(householdIndexToEdit) name: \(nameOfHousehold(householdToEdit.id))")
        if member.id == householdToEdit.head.id {
            householdToEdit.head = member
        } else if let spouse = householdToEdit.spouse, member.id == spouse.id {
            householdToEdit.spouse = member
        } else {
            let otherIds = householdToEdit.others.map { $0.id }
            NSLog("other ids: \(otherIds.joined(separator: ", "))")
            if let otherIndex = householdToEdit.others.firstIndex(where: { $0.id == member.id }) {
                NSLog("found other index \(otherIndex)")
                householdToEdit.others[otherIndex] = member
                NSLog("updated to \(householdToEdit.others[otherIndex].fullName())")
            }
        }
        households[householdIndexToEdit] = householdToEdit
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


enum HouseholdRelation: Hashable {
    static func == (lhs: HouseholdRelation, rhs: HouseholdRelation) -> Bool {
        switch (lhs, rhs) {
        case (.head, .head):
            return true
        case (.spouse, .spouse):
            return true
        case (let .other(lother), let .other(rother)):
            return lother == rother
        default:
            return false
        }
    }

    case head
    case spouse
    case other(Int)
}

struct MemberRelation: Hashable {
    static func == (lhs: MemberRelation, rhs: MemberRelation) -> Bool {
        return lhs.householdId == rhs.householdId && lhs.relation == rhs.relation
    }
    
    var householdId: Id
    var relation: HouseholdRelation
}
