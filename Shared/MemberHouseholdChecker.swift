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
        ///For each member, does the listed household contain the member?
        for member in document.activeMembers {
            let householdOfRecord = document.household(byId: member.household)
            let status = householdOfRecord.contains(member: member.id)
            if status == .notMember {
                report.append("\(member.fullName()) not in household of record, id '\(member.household)'")
            }
            ///Is there any other household that purports to contain the member?
            for household in document.households {
                if household.id == member.household { continue }
                let status = household.contains(member: member.id)
                if status != .notMember {
                    report.append("\(member.fullName()) in additional household '\(household.name ?? "[no name]")', id '\(household.id)'")
                }
            }
        }
        ///For each household, does each member it contains point back to it?
        for household in document.households {
            checkReverse(memberId: household.head, household: household, report: &report)
            if let spouseId = household.spouse {
                checkReverse(memberId: spouseId, household: household, report: &report)
            }
            for otherId in household.others {
                checkReverse(memberId: otherId, household: household, report: &report)
            }
        }
        if report.count < 1 {
            report = ["no results"] //indicate something!
        }
        NSLog("end member-household check")
        return report
    }
    
    private func checkReverse(memberId: ID,
                              household: NormalizedHousehold,
                              report: inout [String]) {
        let member = document.member(byId: memberId)
        if member.household != household.id {
            report.append("Household listed for member '\(member.fullName())' does not agree with household '\(household.name ?? "[none]")' (ID \(household.id))")
        }
    }
    
    
}
