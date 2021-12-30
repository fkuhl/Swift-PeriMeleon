//
//  MoveToHouseholdNewSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/30/21.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdNewSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var memberId: ID
    @State var address: Address = Address()
    @Binding var showingSheet: Bool

    var body: some View {
        Form {
            Text("Move member '\(document.nameOf(member: memberId))' to new household?")
            Text("There is no undo!").font(.headline)
            Section { //Section to group in sets of <= 10
                EditOptionalTextView(caption: "address:", text: $address.address)
                EditOptionalTextView(caption: "address2:", text: $address.address2)
                EditOptionalTextView(caption: "city:", text: $address.city)
                EditOptionalTextView(caption: "state:", text: $address.state)
                EditOptionalTextView(caption: "postal code:", text: $address.postalCode)
                EditOptionalTextView(caption: "country:", text: $address.country)
                EditOptionalTextView(caption: "email:", text: $address.email, keyboardType: .emailAddress)
                EditOptionalTextView(caption: "home phone:", text: $address.homePhone, keyboardType: .phonePad)
            }
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Move Member", action: moveToNew).padding()
                Spacer()
            }
        }
    }
    
    private func moveToNew() {
        let member = document.member(byId: memberId)
        var oldHousehold = document.household(byId: member.household)
        //Retrieve old before changing as side-effect of making new!
        _ = makeNewHousehold(memberId: memberId,
                             address: address)
        switch oldHousehold.statusOf(member: memberId) {
        case .head:
            if let spouseId = oldHousehold.spouse {
                //promote spouse to head
                oldHousehold.head = spouseId
                oldHousehold.spouse = nil
                document.update(household: oldHousehold)
            } else {
                if oldHousehold.others.count == 0 {
                    //neither spouse nor others, so empty now--but why do this?
                    document.remove(household: oldHousehold)
                }
                ///NB: case of prospective orphans prevented by limiting drag source.
            }
        case .spouse:
            oldHousehold.spouse = nil
            document.update(household: oldHousehold)
        case .other:
            oldHousehold.remove(other: memberId)
            document.update(household: oldHousehold)
        case .notMember:
            NSLog("Attempt to move member\(document.nameOf(member: memberId)) from household \(oldHousehold.name ?? "[none]") to which it did not belong")
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private func makeNewHousehold(memberId: ID, address: Address) -> NormalizedHousehold {
        var newHousehold = NormalizedHousehold()
        newHousehold.head = memberId
        newHousehold.name = document.nameOf(member: memberId)
        newHousehold.address = address
        document.add(household: newHousehold)
        var member = document.member(byId: memberId)
        member.household = newHousehold.id
        member.dateLastChanged = Date()
        document.update(member: member)
        return newHousehold
    }
}

struct MoveToHouseholdNewSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdNewSheet(memberId: .constant(mockMember1.id),
                                showingSheet: .constant(true))
            .environmentObject(mockDocument)
    }
}
