//
//  RemoveMemberSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/30/21.
//

import SwiftUI
import PMDataTypes

struct RemoveMemberSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var memberId: ID
    @Binding var relationships: [HouseholdMembership]
    @Binding var removalState: RemoveMemberState
    @Binding var showingSheet: Bool
    
    var body: some View {
        switch removalState {
        case .enteringData:
            Form {
                Text("This should never appear!")
                merelyDismiss
            }
        case .memberInNoHousehold:
            memberInNoHousehold
        case .memberInMultipleHouseholds:
            memberInMultipleHouseholds
        case .memberIsHead:
            memberIsHead
        case .memberIsNotHead:
            memberIsNotHead
        }
    }
    
    private var memberIsNotHead: some View {
        Form {
            Text("Remove member '\(document.nameOf(member: memberId))' ?")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Remove", action: removeMember).padding()
                Spacer()
            }
        }
    }
    
    //member is sole member of household, i.e., its head.
    private func removeMemberAndHousehold() {
        let member = document.member(byId: memberId)
        let household = document.household(byId: member.household)
        document.remove(member: member)
        document.remove(household: household)
        presentationMode.wrappedValue.dismiss()
    }
    
    private var memberIsHead: some View {
        Form {
            if document.containsOnlyHead(household: relationships[0].household) {
                Text("Removing member '\(document.nameOf(member: memberId))' will also remove the household.")
                Text("There is no undo!").font(.headline)
                HStack {
                    Spacer()
                    SolidButton(text: "Cancel", action: {
                                    presentationMode.wrappedValue.dismiss() }).padding()
                    SolidButton(text: "Remove", action: removeMemberAndHousehold).padding()
                    Spacer()
                }
            } else {
                Text("Removing member '\(document.nameOf(member: memberId))' will leave other household members orphans. This must be resolved.").font(.headline)
                merelyDismiss
            }
        }
    }
    
    //member is not head of this household
    private func removeMember() {
        let member = document.member(byId: memberId)
        var household = document.household(byId: member.household)
        document.remove(member: member)
        if household.spouse == member.id {
            household.spouse = nil
            document.update(household: household)
        } else {
            var others = household.others
            if let index = others.firstIndex(of: memberId) {
                others.remove(at: index)
                household.others = others
                document.update(household: household)
            } else {
                NSLog("member '\(document.nameOf(member: memberId))' was neither spouse nor other")
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private var merelyDismiss: some View {
        HStack {
            Spacer()
            SolidButton(text: "Dismiss", action: {
                            presentationMode.wrappedValue.dismiss() })
            Spacer()
        }.padding()
    }
    
    private var memberInNoHousehold: some View {
        Form {
            Text("Member '\(document.nameOf(member: memberId))' appears in no households. This is suspect and should be investigated before attempting to remove the member.").font(.headline)
            merelyDismiss
        }
    }
    
    private var memberInMultipleHouseholds: some View {
        Form {
            Text("Member '\(document.nameOf(member: memberId))' appears in several households:")
            List {
                ForEach(relationships, id: \.self) { relationship in
                    Text(document.nameOf(household: relationship.household))
                }
            }
            Text("This is suspect and should be resolved before the member is removed.").font(.headline)
            merelyDismiss
        }
    }
}

struct RemoveMemberSheet_Previews: PreviewProvider {
    static var previews: some View {
        //entering data
        RemoveMemberSheet(memberId: .constant(""),
                          relationships: .constant([HouseholdMembership]()),
                          removalState: .constant(.enteringData),
                          showingSheet: .constant(true))
        .environmentObject(mockDocument)
        
        //member in mult households
        RemoveMemberSheet(memberId: .constant("123"),
                          relationships: .constant([HouseholdMembership(household: "abc", relationship: .head),HouseholdMembership(household: "abc", relationship: .spouse)]),
                          removalState: .constant(.memberInMultipleHouseholds),
                          showingSheet: .constant(true))
        .environmentObject(mockDocument)
        
        //member is head, and there are other members
        RemoveMemberSheet(memberId: .constant("123"),
                          relationships: .constant([HouseholdMembership(household: "abc", relationship: .head)]),
                          removalState: .constant(.memberIsHead),
                          showingSheet: .constant(true))
        .environmentObject(mockDocument)
        
        //member is head and no other members
        RemoveMemberSheet(memberId: .constant(mockMember3.id),
                          relationships: .constant([HouseholdMembership(household: "pqr", relationship: .head)]),
                          removalState: .constant(.memberIsHead),
                          showingSheet: .constant(true))
        .environmentObject(mockDocument)
        
        //member is not head
        RemoveMemberSheet(memberId: .constant(mockMember2.id),
                          relationships: .constant([HouseholdMembership(household: "abc", relationship: .spouse)]),
                          removalState: .constant(.memberIsNotHead),
                          showingSheet: .constant(true))
        .environmentObject(mockDocument)
    }
}
