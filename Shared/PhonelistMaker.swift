//
//  PhonelistMaker.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/31/20.
//

import Foundation
import PMDataTypes

struct PhonelistMaker {
    var model: Model
    let note = "PeriMeleon \(dateFormatter.string(from: Date()))"
    
    func make(from members: [Member]) -> String {
        var csvReturn = "Last Name,First Name,Display Name,Home Street,Home Street 2,Home City,Home State,Home ZIP,Home Country,Home Phone,Email (home),Email (work),Phone (mobile),Phone (work),Note"
        csvReturn = members.reduce(csvReturn) { thusFar, member in
            "\(thusFar)\n\(nameContrib(member)),\(addressContrib(member)),\(note)"
        }
        
        return csvReturn
    }
    
    func nameContrib(_ member: Member) -> String {
        "\(member.familyName),\(member.nickname ?? member.givenName),\"\(member.displayName())\""
    }
    
    func addressContrib(_ member: Member) -> String {
        let household = model.household(byId: member.household)
        let homeEmail = member.eMail ?? household.address?.email
        return "\(household.address?.address ?? ""),\(household.address?.address2 ?? ""),\(household.address?.city ?? ""),\(household.address?.state ?? ""),\(household.address?.postalCode ?? ""),\(household.address?.country ?? ""),\(household.address?.homePhone ?? ""),\(homeEmail ?? ""),\(member.workEmail ?? ""),\(member.mobilePhone ?? ""),\(member.workPhone ?? "")"
    }
}
