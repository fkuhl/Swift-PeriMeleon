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
    var sh: SortedArray<NormalizedHousehold>
    var sm: SortedArray<Member>
    
    init() {
        h = [ID : NormalizedHousehold]()
        m = [ID : Member]()
        sh = SortedArray<NormalizedHousehold>(unsorted: h.values,
                                              areInIncreasingOrder: compareHouseholds)
        sm = SortedArray<Member>(unsorted: m.values,
                                 areInIncreasingOrder: compareMembers)
    }
    
    init(h: [ID : NormalizedHousehold],
         m: [ID : Member],
         sh: SortedArray<NormalizedHousehold>,
         sm: SortedArray<Member>) {
        self.h = h
        self.m = m
        self.sh = sh
        self.sm = sm
    }
}
