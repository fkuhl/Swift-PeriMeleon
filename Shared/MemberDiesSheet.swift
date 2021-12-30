//
//  MemberDiesSheet.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 12/23/21.
//

import SwiftUI
import PMDataTypes

struct MemberDiesSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var memberId: ID
    @Binding var dateDied: Date
    @Binding var comment: String
    @Binding var orphans: [ID]
    @Binding var removalState: MemberDiesState
    @Binding var showingSheet: Bool

    var body: some View {
        switch removalState {
        case .enteringData:
            Form {
                Text("This should never appear!")
                merelyDismiss
            }
        case .removeSpouse, .removeDependent:
            removeSpouseOrDependent
        case .removeHead:
            removeHead
        case .prospectiveOrphans:
            prospectiveOrphans
        }
    }
    
    private var removeSpouseOrDependent: some View {
        Form {
            Text("Record member '\(document.nameOf(member: memberId))' as deceased?")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Record Member As Deceased", action: removeFromOldHouseholdAndDismiss).padding()
                Spacer()
            }
        }
    }
    
    /**
     Deceased is simply removed from old household and placed in new household.
     - Precondition: Member is not head of old household.
     */
    private func removeFromOldHouseholdAndDismiss() {
        let oldHouseholdId = document.member(byId: memberId).household
        var oldHousehold = document.household(byId: oldHouseholdId)
        if removalState == .removeSpouse {
            oldHousehold.spouse = nil
        } else if removalState == .removeDependent {
            oldHousehold.remove(other: memberId)
        }
        document.update(household: oldHousehold)
        recordMemberDead(id: memberId)
        presentationMode.wrappedValue.dismiss()
    }
    
    /**
     Adjust deceased member to mark them dead.
     
     - Postcondition: Member has been marked as dead.
     - Postcondition: Member has been moved to a new houehold, which has been added to the document.
     - Postcondition: Member's entry in document is updated.
     - Postcondition: Everything has been accomplished except adjustments to the losing household.
     */
    private func recordMemberDead(id: ID) {
        var member = document.member(byId: id)
        /**
         Although members imported through PMImporter are carefully placed in the
         "MansionInTheSky" there really is no need to do this. Each member who dies can be
         placed in their own household. This is preferable because "MansionInTheSky" isn't
         otherwise distinguishable. Frankly, it was a mistake to create it in the import.
         */
        //Make member's new household
        var deceasedHousehold = NormalizedHousehold()
        deceasedHousehold.head = memberId
        deceasedHousehold.name = member.displayName()
        document.add(household: deceasedHousehold)
        //Now make changes to mark member as deceased
        member.household = deceasedHousehold.id
        member.status = .DEAD
        member.resident = false
        var transaction = PMDataTypes.Transaction()
        transaction.date = dateDied
        transaction.type = .DIED
        transaction.comment = comment
        var trans = member.transactions
        trans.append(transaction)
        member.transactions = trans
        member.dateLastChanged = Date()
        document.update(member: member)
    }
    
    private var removeHead: some View {
        Form {
            Text("Record member '\(document.nameOf(member: memberId))' as deceased?")
            Text("The member's spouse (if any) will become the head of the household.")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Record Member As Deceased", action: removeMemberPromoteSpouseAndDismiss).padding()
                Spacer()
            }
        }
    }
    
    /**
     Remove deceased to new household; make spouse the head of the old household.
     - Precondition: Member is head of old household.
     - Postcondition: If there is spouse in old household, becomes head.
     */
    private func removeMemberPromoteSpouseAndDismiss() {
        let oldHouseholdId = document.member(byId: memberId).household
        var oldHousehold = document.household(byId: oldHouseholdId)
        if let spouseId = oldHousehold.spouse {
            var spouse = document.member(byId: spouseId)
            oldHousehold.head = spouseId
            oldHousehold.spouse = nil
            document.update(household: oldHousehold)
            spouse.maritalStatus = .SINGLE
            spouse.dateLastChanged = Date()
            document.update(member: spouse)
        } else {
            if oldHousehold.others.count == 0 {
                //remove empty household
                document.remove(household: oldHousehold)
            }
        }
        recordMemberDead(id: memberId)
        presentationMode.wrappedValue.dismiss()
    }
    
    /**
     Recording head of household will leave orphans.
     */
    private var prospectiveOrphans: some View {
        Form {
            Text("Recording member '\(document.nameOf(member: memberId))' as deceased would leave these orphans. This must be resolved first.").font(.headline)
            List {
                ForEach(orphans, id: \.self) { orphan in
                    Text(document.nameOf(member: orphan)).font(.subheadline)
                }
            }
            merelyDismiss
        }
    }

    private var merelyDismiss: some View {
        HStack {
            Spacer()
            SolidButton(text: "Dismiss", action: {
                presentationMode.wrappedValue.dismiss() })
            Spacer()
        }.padding()
    }}

struct MemberDiesSheet_Previews: PreviewProvider {
    static var previews: some View {
        MemberDiesSheet(memberId: .constant(mockMember1.id),
                        dateDied: .constant(Date()),
                        comment: .constant("This is a comment"),
                        orphans: .constant([ID]()),
                        removalState: .constant(.removeSpouse),
                        showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".removeSpouse")
    }
}
