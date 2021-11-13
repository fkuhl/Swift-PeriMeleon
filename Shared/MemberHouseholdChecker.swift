//
//  MemberHouseholdChecker.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/13/21.
//

import SwiftUI
import PMDataTypes

struct MemberHouseholdChecker {
    @ObservedObject var document: PeriMeleonDocument
    
    func check() -> [String] {
        NSLog("begin member-household check")
        var report = [String]()
        for member in document.activeMembers {
            let householdOfRecord = document.household(byId: member.household)
            let status = householdOfRecord.contains(member: member.id)
            if status == .notMember {
                report.append("\(member.fullName()) not in household of record, id '\(member.household)'")
            }
            for household in document.households {
                if household.id == member.household { continue }
                let status = household.contains(member: member.id)
                if status != .notMember {
                    report.append("\(member.fullName()) in additional household '\(household.name ?? "[no name]")', id '\(household.id)'")
                }
            }
        }
        if report.count < 1 {
            report = ["no results"] //indicate something!
        }
        NSLog("end member-household check")
        return report
    }
    
    
}
