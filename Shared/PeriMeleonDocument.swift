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

    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    
    init() {
        self.households = [Household]()
    }
    
    init(fileWrapper: FileWrapper, contentType: UTType) throws {
        if let data = fileWrapper.regularFileContents {
            self.households = try jsonDecoder.decode([Household].self, from: data)
            NSLog("read \(self.households.count) households")
        }
    }


    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            NSLog("corrupt file")
            return
        }
        do {
            self.households = try jsonDecoder.decode([Household].self, from: data)
            NSLog("read \(self.households.count) households")
        } catch {
            let err = error as! DecodingError
            NSLog("decode error \(err)")
        }
    }
    
    //which of these?
    func write(to fileWrapper: inout FileWrapper, contentType: UTType) throws {
        let data = try jsonEncoder.encode(self.households)
        NSLog("writing \(data.count) bytes")
        fileWrapper = FileWrapper(regularFileWithContents: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try jsonEncoder.encode(self.households)
        NSLog("writing \(data.count) bytes")
        return .init(regularFileWithContents: data)
    }
}
