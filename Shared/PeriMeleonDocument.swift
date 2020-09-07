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
    var households = [Household]()
    var activeHouseholds = [Household]()
    var members = [Member]()
    var activeMembers = [Member]()

    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    static var writableContentTypes: [UTType] { [.periMeleonRollsDocument] }

    init() {
        self.households = [Household]()
    }
    
//    init(fileWrapper: FileWrapper, contentType: UTType) throws {
//        if let data = fileWrapper.regularFileContents {
//            self.households = try jsonDecoder.decode([Household].self, from: data)
//            NSLog("read \(self.households.count) households from init fileWrapper")
//        }
//    }


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
            activeHouseholds = households.filter { $0.head.status.isActive() }
            NSLog("found \(activeHouseholds.count) active households")
            let unsortedMembers = pullMembers(from: households)
            members = unsortedMembers.sorted{
                $0.fullName() < $1.fullName()
            }
            NSLog("found \(members.count) members")
            activeMembers = members.filter{ $0.status.isActive()}
            NSLog("found \(activeMembers.count) active mambers")
        } catch {
            let err = error as! DecodingError
            NSLog("decode error \(err)")
        }
    }
    
//    func write(to fileWrapper: inout FileWrapper, contentType: UTType) throws {
//        let data = try jsonEncoder.encode(self.households)
//        NSLog("writing \(data.count) bytes")
//        fileWrapper = FileWrapper(regularFileWithContents: data)
//    }
    
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
