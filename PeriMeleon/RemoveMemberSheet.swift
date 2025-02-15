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
    @Binding var readyForRemovals: [ID]
    @Binding var suspects: [ID]
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
        case .readyToBeRemoved:
            readyToBeRemoved
        case .potentialOrphansOnly:
            prospectiveOrphans
        case .orphansAndReadies:
            orphansAndReadies
        }
    }
    
    /// Member is in no household.
    private var memberInNoHousehold: some View {
        Form {
            Text("Member '\(document.nameOf(member: memberId))' appears in no households. Remove member entry anyway?")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Remove Member Entry", action: removeMemberEntryAndDismiss).padding()
                Spacer()
            }
        }
    }
    
    private func removeMemberEntryAndDismiss() {
        removeMemberEntry()
        presentationMode.wrappedValue.dismiss()
    }
    
    ///Remove just the entry for the member
    private func removeMemberEntry () {
        let member = document.member(byId: memberId)
        NSLog("Removing entry for member\(document.nameOf(member: memberId))")
        document.remove(member: member)
    }

    /// Member appears  in one or more households, but never as head where household has other members.
    private var readyToBeRemoved: some View {
        Form {
            Text("Member '\(document.nameOf(member: memberId))' appears in these households:").font(.headline)
            List {
                ForEach(readyForRemovals, id: \.self) { suspect in
                    Text(document.nameOf(household: suspect)).font(.subheadline)
                }
            }
            Text("1. Where member is head of otherwise empty household, the household will be removed.")
            Text("2. Where member is not the head, member will be removed from household; household otherwise unaffected.")
            Text("3. Member entry will be removed.")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Remove Member", action: removeMemberAndHouseholds).padding()
                Spacer()
            }
        }
    }
    
    private func removeMemberAndHouseholds() {
        removeMemberFromReadies()
        removeMemberEntry()
        presentationMode.wrappedValue.dismiss()
    }
    
    ///Remove member from all households where it appears. If household is thus emptied, remove it.
    private func removeMemberFromReadies() {
        for householdId in readyForRemovals {
            var household = document.household(byId: householdId)
            if household.head == memberId {
                NSLog("removing household\(document.nameOf(household: household)) because will be empty")
                document.remove(household: household)
            } else if household.spouse == memberId {
                household.spouse = nil
                NSLog("Updating household\(document.nameOf(household: household)) because spouse removed")
                document.update(household: household)
            } else {
                var others = household.others
                if let index = others.firstIndex(of: memberId) {
                    others.remove(at: index)
                    household.others = others
                    NSLog("Updating household\(document.nameOf(household: household)) because dependent removed")
                    document.update(household: household)
                } else {
                    NSLog("member '\(document.nameOf(member: memberId))' was neither spouse nor other")
                }
            }
        }
    }
    
    /// Removing member will create orphans
    private var prospectiveOrphans: some View {
        Form {
            Text("Removing member '\(document.nameOf(member: memberId))' would leave other household members orphans in the following households. These households must be resolved before member can be removed.").font(.headline)
            Text("Households with prospective orphans:")
            List {
                ForEach(suspects, id: \.self) { suspect in
                    Text(document.nameOf(household: suspect)).font(.subheadline)
                }
            }
            merelyDismiss
        }
    }
    
    /// Potential orphans, and some readies
    private var orphansAndReadies: some View {
        Form {
            Text("Removing member '\(document.nameOf(member: memberId))' would leave other household members orphans in the following households. Member entry will not be removed, nor these households changed.").font(.headline)
            List {
                ForEach(suspects, id: \.self) { suspect in
                    Text(document.nameOf(household: suspect)).font(.subheadline)
                }
            }
            Text("Member appears '\(document.nameOf(member: memberId))' in these households:").font(.headline)
            List {
                ForEach(readyForRemovals, id: \.self) { suspect in
                    Text(document.nameOf(household: suspect)).font(.subheadline)
                }
            }
            Text("1. Where member is head of otherwise empty household, the household will be removed.")
            Text("2. Where member is not the head, member will be removed from household; household otherwise unaffected.")
            Text("3. Member entry will NOT be removed.")
            Text("There is no undo!").font(.headline)
            HStack {
                Spacer()
                SolidButton(text: "Cancel", action: {
                                presentationMode.wrappedValue.dismiss() }).padding()
                SolidButton(text: "Remove Member from Households", action: removeFromReadies).padding()
                Spacer()
            }
        }
    }
    
    private func removeFromReadies() {
        removeMemberFromReadies()
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
}

struct RemoveMemberSheet_Previews: PreviewProvider {
    static var previews: some View {
        //entering data
        RemoveMemberSheet(memberId: .constant(""),
                          readyForRemovals: .constant([ID]()),
                          suspects: .constant([ID]()),
                          removalState: .constant(.enteringData),
                          showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".enteringData")
        
        //member is in no household
        RemoveMemberSheet(memberId: .constant(mockMember3.id),
                          readyForRemovals: .constant([]),
                          suspects: .constant([]),
                          removalState: .constant(.memberInNoHousehold),
                          showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".memberInNoHousehold")

        //member in mult households: both readys and suspects
        RemoveMemberSheet(memberId: .constant("123"),
                          readyForRemovals: .constant(["abc", "pqr"]),
                          suspects: .constant(["abc", "pqr"]),
                          removalState: .constant(.readyToBeRemoved),
                          showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".readyToBeRemoved")
        
        //Only suspects
        RemoveMemberSheet(memberId: .constant("123"),
                          readyForRemovals: .constant([]),
                          suspects: .constant(["abc", "pqr"]),
                          removalState: .constant(.potentialOrphansOnly),
                          showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".potentialOrphans")
        
        //suspects and readies
        RemoveMemberSheet(memberId: .constant("123"),
                          readyForRemovals: .constant(["abc", "pqr"]),
                          suspects: .constant(["abc", "pqr"]),
                          removalState: .constant(.orphansAndReadies),
                          showingSheet: .constant(true))
            .environmentObject(mockDocument)
            .previewDisplayName(".orphansAndReadies")
    }
}
