//
//  Model.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 7/5/21.
//

import SwiftUI
import PMDataTypes

struct Model {
    var h: [ID : NormalizedHousehold]
    var m: [ID : Member]
    
    init() {
        h = [ID : NormalizedHousehold]()
        m = [ID : Member]()
    }
    
    init(h: [ID : NormalizedHousehold], m: [ID : Member]) {
        self.h = h
        self.m = m
    }
}
