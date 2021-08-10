//
//  PeriMeleonUnitTests.swift
//  PeriMeleonUnitTests
//
//  Created by Frederick Kuhl on 8/7/21.
//

import XCTest
@testable import PeriMeleon

class GoodDocumentUnitTests: XCTestCase {
    var document: PeriMeleonDocument?

    override func setUpWithError() throws {
        let filePath = Bundle.main.url(forResource: "test-doc", withExtension: "pmrolls")
        let data = try Data(contentsOf: filePath!)
        document = PeriMeleonDocument(data: data)
    }

    override func tearDownWithError() throws {
        document = nil
    }

    func test_PMDoc_ReadGoodDoc_StateIsNormal() throws {
        XCTAssertEqual(document?.state, .normal)
    }

    func test_PMDoc_ReadGoodDoc_RightNumberOfHouseholds() throws {
        XCTAssertEqual(document?.householdsById.count, 1)
        XCTAssertEqual(document?.households.count, 1)
    }

    func test_PMDoc_ReadGoodDoc_RightNumberOfActiveHouseholds() throws {
        XCTAssertEqual(document?.activeHouseholds.count, 1)
    }

    func test_PMDoc_ReadGoodDoc_RightNumberOfMembers() throws {
        XCTAssertEqual(document?.membersById.count, 3)
        XCTAssertEqual(document?.members.count, 3)
    }

    func test_PMDoc_ReadGoodDoc_RightNumberOfActiveMembers() throws {
        XCTAssertEqual(document?.activeMembers.count, 3)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
