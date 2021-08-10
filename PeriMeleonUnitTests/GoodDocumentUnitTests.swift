//
//  PeriMeleonUnitTests.swift
//  PeriMeleonUnitTests
//
//  Created by Frederick Kuhl on 8/7/21.
//

import XCTest
@testable import PeriMeleon
import PMDataTypes

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

    func test_PMDoc_ReadGoodDoc_CorrectHouseholdByID() throws {
        XCTAssertEqual(document?.nameOf(household: "1"), "Hornswoggle, Horatio")
    }

    func test_PMDoc_ReadGoodDoc_CorrectMemberByID() throws {
        XCTAssertEqual(document?.nameOf(member: "2"), "Hornswoggle, Hermione")
    }

    func test_PMDoc_ReadGoodDoc_AddMember() throws {
        let previousChangeCount = document!.changeCount
        var newMember = Member()
        newMember.familyName = "Hornswoggle"
        newMember.givenName = "Hamlet"
        document?.add(member: newMember)
        
        XCTAssertEqual(document?.membersById.count, 4)
        XCTAssertEqual(document?.nameOf(member: newMember.id), "Hornswoggle, Hamlet")
        XCTAssertGreaterThan(document!.changeCount, previousChangeCount)
    }

    func test_PMDoc_ReadGoodDoc_UpdateMember() throws {
        let previousChangeCount = document!.changeCount
        var member = document?.membersById["3"]
        member?.nickname = "Heppy"
        document?.update(member: member!)
        
        XCTAssertEqual(document?.membersById.count, 3)
        XCTAssertEqual(document?.member(byId: "3").nickname, "Heppy")
        XCTAssertGreaterThan(document!.changeCount, previousChangeCount)
    }

    func test_PMDoc_ReadGoodDoc_AddHousehold() throws {
        let previousChangeCount = document!.changeCount
        var newMember = Member()
        newMember.familyName = "Farkle"
        newMember.givenName = "Fred"
        document?.add(member: newMember)
        var newHousehold = NormalizedHousehold()
        newHousehold.head = newMember.id
        document?.add(household: newHousehold)
        
        XCTAssertEqual(document?.householdsById.count, 2)
        XCTAssertEqual(document?.nameOf(household: newHousehold), "Farkle, Fred")
        XCTAssertGreaterThan(document!.changeCount, previousChangeCount)
    }

    func test_PMDoc_ReadGoodDoc_UpdateHousehold() throws {
        let previousChangeCount = document!.changeCount
        var address = Address()
        address.address = "some street addr"
        address.city = "City"
        var household = document?.household(byId: "1")
        household?.address = address
        document?.update(household: household!)
        
        XCTAssertEqual(document?.householdsById.count, 1)
        XCTAssertEqual(document?.household(byId: "1").address?.address, "some street addr")
        XCTAssertGreaterThan(document!.changeCount, previousChangeCount)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
