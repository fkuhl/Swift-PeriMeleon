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
        let expectation = XCTestExpectation(description: "decode document data")
        let filePath = Bundle.main.url(forResource: "test-bad-doc", withExtension: "pmrolls")
        let data = try Data(contentsOf: filePath!)
        document = PeriMeleonDocument(data: data, normalCompletion: { model in
            self.document?.setModel(model: model)
            expectation.fulfill()
        }, cannotDecodeCompletion: { explanation in
            self.document?.setCannotDecode(explanation: explanation)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 2)
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
