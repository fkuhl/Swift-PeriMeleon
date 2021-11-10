//
//  DirectoryMaker.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/22/21.
//

import SwiftUI
import PMDataTypes

struct DirectoryMaker {
    @ObservedObject var document: PeriMeleonDocument

    func make() -> [String] {
        NSLog("begin dir")
        var directory = ["Directory as of \(dateFormatter.string(from: Date()))"] + [""]
        directory = document.activeHouseholds.reduce(directory) { thusFar, household in
            thusFar + [""] + householdEntry(household)
        }
        NSLog("end dir")
        return directory
    }
    
    func householdEntry(_ household: NormalizedHousehold) -> [String] {
        var householdTitle = document.nameOf(household: household.id)
        let head = document.member(byId: household.head)
        if let spouseID = household.spouse {
            let spouse = document.member(byId: spouseID)
            if spouse.familyName == head.familyName {
                householdTitle += " & \(spouse.firstName())"
            } else {
                householdTitle += " & \(spouse.firstName()) \(spouse.familyName)"
            }
        }
        
        var address = [household.address?.address ?? ""]
        if !nugatory(household.address?.address2) {
            address = address + [household.address?.address2 ?? ""]
        }
        address = address + ["\(household.address?.city ?? ""), \(household.address?.state ?? "") \(household.address?.postalCode ?? "")"]
        if !nugatory(household.address?.country) {
            address = address + ["\(household.address?.country ?? "")"]
        }
        if !nugatory(household.address?.homePhone) || !nugatory(household.address?.email) {
            address = address +  [" \(household.address?.homePhone ?? "") \(household.address?.email ?? "")"]
        }
        
        var entry = [householdTitle] + address
        entry = entry + ["\(head.firstName()): \(head.mobilePhone ?? "") \(head.eMail ?? "")"]
        if let spouseID = household.spouse {
            let spouse = document.member(byId: spouseID)
            if !nugatory(spouse.mobilePhone) || !nugatory(spouse.eMail) {
                entry = entry + ["\(spouse.firstName()): \(spouse.mobilePhone ?? "") \(spouse.eMail ?? "")"]
            } else {
                entry = entry + ["\(spouse.firstName())"]
            }
        }
        for otherID in household.others {
            let other = document.member(byId: otherID)
            var otherName = other.firstName()
            if other.familyName != head.familyName {
                otherName += " \(other.familyName)"
            }
            if !nugatory(other.mobilePhone) || !nugatory(other.eMail) {
                entry = entry + ["\(otherName): \(other.mobilePhone ?? "") \(other.eMail ?? "")"]
            } else {
                entry = entry + ["\(otherName)"]
            }
        }
        return entry
    }
}
