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
    
    static var readableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    static var writableContentTypes: [UTType] { [.periMeleonRollsDocument] }
    
    var content: PeriMeleonContent
    
    init() {
        content = PeriMeleonContent()
    }
    
    init(configuration: ReadConfiguration) throws {
        let encryptedContent = configuration.file.regularFileContents
        content = PeriMeleonContent(data: encryptedContent)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: try content.encrypt())
    }
}
