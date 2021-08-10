//
//  BadDocumentUnitTests.swift
//  PeriMeleonUnitTests
//
//  Created by Frederick Kuhl on 8/7/21.
//

import XCTest
@testable import PeriMeleon

class BadDocumentUnitTests: XCTestCase {
    var document: PeriMeleonDocument?

    override func setUpWithError() throws {
        let filePath = Bundle.main.url(forResource: "test-bad-doc", withExtension: "pmrolls")
        let data = try Data(contentsOf: filePath!)
        document = PeriMeleonDocument(data: data)
    }

    override func tearDownWithError() throws {
        document = nil
    }

    func test_PMDoc_ReadBadDoc_StateIsCannotDecode() throws {
        XCTAssertEqual(
            document?.state,
            .cannotDecode(basicError: "The given data was not valid JSON.",
                          codingPath: "",
                          underlyingError: "No string key for value in object around character 422."))
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
