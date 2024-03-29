//
//  MockedData.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/28/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

fileprivate func makeTrans() -> PMDataTypes.Transaction {
    var trans = PMDataTypes.Transaction()
    trans.date = Date()
    trans.type = .RECEIVED
    trans.church = "Some Church"
    return trans
}

fileprivate func makeMv1() -> Member {
    var mv1 = Member()
    mv1.id = "123"
    mv1.familyName = "Hornswoggle"
    mv1.givenName = "Horatio"
    mv1.middleName = "Quincy"
    mv1.previousFamilyName = nil
    mv1.nickname = "Horry"
    mv1.sex = Sex.MALE
    mv1.dateOfBirth = dateFormatter.date(from: "1990-05-07")
    mv1.household = "0"
    mv1.eMail = "horatio@nonsense.com"
    mv1.mobilePhone = "888-555-1212"
    mv1.baptism = "Utopia: 1970-01-01"
    mv1.transactions = [ makeTrans() ]
    return mv1
}
let mockMember1 = makeMv1()

fileprivate func makeMv2() -> Member {
    var mockMember2 = Member(
        familyName: "Hornswoggle",
        givenName: "Hortense",
        middleName: "",
        previousFamilyName: "Havisham",
        nickname: "",
        sex: Sex.FEMALE,
        household: "0",
        eMail: "hortense@nonsense.com",
        mobilePhone: "888-555-1213",
        baptism: "Somewhere: 1970-01-01")
    mockMember2.dateOfBirth = dateFormatter.date(from: "2000-06-09")
    return mockMember2
}

let mockMember2 = makeMv2()

fileprivate func makeMv3() -> Member {
    var mockMember3 = Member(
        familyName: "Farkle",
        givenName: "Fred",
        middleName: "",
        previousFamilyName: "",
        nickname: "",
        sex: Sex.FEMALE,
        household: "0",
        eMail: "farkle@nonsense.com",
        mobilePhone: "888-555-1213",
        baptism: "Somewhere: 1970-01-01")
    mockMember3.dateOfBirth = dateFormatter.date(from: "2000-06-09")
    return mockMember3
}

let mockMember3 = makeMv3()

let mockAddress = Address(
    address: "123 Plesant Avenue",
    city: "Pleasantown",
    state: "VA",
    postalCode: "54321"
)

var mockHousehold1 = NormalizedHousehold(
    id: "abc",
    head: mockMember1.id,
    spouse: mockMember2.id,
    others: [ID](),
    address: mockAddress
)

var mockHousehold2 = NormalizedHousehold(
    id: "pqr",
    head: mockMember3.id,
    spouse: nil,
    others: [ID](),
    address: mockAddress
)

fileprivate func makeModel() -> Model {
    var model = Model()
    model.m[mockMember1.id] = mockMember1
    model.m[mockMember2.id] = mockMember2
    model.m[mockMember3.id] = mockMember3
    model.h[mockHousehold1.id] = mockHousehold1
    model.h[mockHousehold2.id] = mockHousehold2
    return model
}

//let mockModel = makeModel()

let mockDocument = PeriMeleonDocument(model: makeModel())

