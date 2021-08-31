//
//  RemoveMemberView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/30/21.
//

import SwiftUI
import PMDataTypes

struct RemoveMemberView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var memberId: ID = ""
    @State private var relationships = [HouseholdMembership]()
    @State private var removalState: RemoveMemberState = .enteringData
    @State private var showingSheet = false

    var body: some View {
        Form {
            Text("Remove member").font(.title)
            Text("This is to be used only to maintain the data, i.e., to correct a problem. Normally a member is never actually removed from the rolls; they merely become inactive. It is NOT to be used for any normal membership transaction.").font(.headline)
            ChooseMemberView(caption: "Member to be removed:", memberId: $memberId)
            HStack {
                Spacer()
                SolidButton(text: "Check removal", action: checkRemoval)
                Spacer()
            }.padding()
        }
        .sheet(isPresented: $showingSheet) {
            RemoveMemberSheet(memberId: $memberId,
                              relationships: $relationships,
                              removalState: $removalState,
                              showingSheet: $showingSheet)
        }
    }
    
    func checkRemoval() {
        removalState = .enteringData
        relationships = document.findInHouseholds(member: memberId)
        NSLog("findInHouseholds returned \(relationships.count) entries")
        if relationships.count == 0 { removalState = .memberInNoHousehold }
        else if relationships.count > 1 { removalState = .memberInMultipleHouseholds }
        else {
            if relationships[0].relationship == .head { removalState = .memberIsHead }
            else { removalState = .memberIsNotHead }
        }
        NSLog("removalState: \(removalState)")
        showingSheet = removalState != .enteringData
    }
}

struct RemoveMemberView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveMemberView()
            .environmentObject(mockDocument)
    }
}
