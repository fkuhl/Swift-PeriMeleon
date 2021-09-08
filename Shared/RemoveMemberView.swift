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
    @State private var readyForRemovals = [ID]()
    @State private var suspects = [ID]()
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
                              readyForRemovals: $readyForRemovals,
                              suspects: $suspects,
                              removalState: $removalState,
                              showingSheet: $showingSheet)
        }
    }
    
    func checkRemoval() {
        removalState = .enteringData
        let checkReturn = document.checkForRemovals(member: memberId)
        readyForRemovals = checkReturn.ready
        suspects = checkReturn.suspect
        NSLog("checkForRemovals returned \(readyForRemovals.count) ready, \(suspects.count) suspects")
        if suspects.count == 0 {
            if readyForRemovals.count == 0 { removalState = .memberInNoHousehold }
            else { removalState = .readyToBeRemoved }
        } else {
            if readyForRemovals.count == 0 { removalState = .potentialOrphansOnly }
            else { removalState = .orphansAndReadies }
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
