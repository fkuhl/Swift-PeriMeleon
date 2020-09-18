//
//  PeriMeleonDocument.swift
//  Shared
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI
import UniformTypeIdentifiers
import PMDataTypes

extension UTType {
    static let periMeleonRollsDocument = UTType(exportedAs: "com.tyndalesoft.PeriMeleon.rolls")
}

struct PeriMeleonDocument: FileDocument {
    enum State {
        case noKey
        case cannotRead(errorDescription: String)
        case cannnotDecrypt
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

    init() {
        self.households = [Household]()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            NSLog("corrupt file")
            return
        }
        do {
            let unsortedHouseholds = try jsonDecoder.decode([Household].self, from: data)
            households = unsortedHouseholds.sorted {
                $0.head.fullName() < $1.head.fullName()
            }
            NSLog("read \(self.households.count) households from init config")
        } catch {
            let err = error as! DecodingError
            NSLog("decode error \(err)")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try jsonEncoder.encode(self.households)
        NSLog("writing \(data.count) bytes")
        return .init(regularFileWithContents: data)
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
