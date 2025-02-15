//
//  MoveToHouseholdOtherSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/31/21.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdOtherSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var memberId: ID
    @Binding var targetHousehold: NormalizedHousehold
    
    var body: some View {
        Form {
            Text("Move member '\(document.nameOf(member: memberId))' to household '\(targetHousehold.name ?? "[none]")'?")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Move Member", action: moveMember).padding()
                Spacer()
            }
        }
    }
    
    private func moveMember() {
        var member = document.member(byId: memberId)
        var oldHousehold = document.household(byId: member.household)
        assert(oldHousehold.statusOf(member: memberId) == .other,
               "member \(member.fullName()) is head or spouse in previous household")
        var targetOthers = targetHousehold.others
        targetOthers.append(memberId)
        targetHousehold.others = targetOthers
        document.update(household: targetHousehold)
        oldHousehold.remove(other: memberId)
        document.update(household: oldHousehold)
        member.household = targetHousehold.id
        document.update(member: member)
        presentationMode.wrappedValue.dismiss()
    }
}

struct MoveToHouseholdOtherSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdOtherSheet(
            memberId: .constant(mockMember1.id),
            targetHousehold: .constant(mockHousehold1))
            .environmentObject(mockDocument)
    }
}
