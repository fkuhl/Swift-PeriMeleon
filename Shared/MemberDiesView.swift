//
//  MemberDiesView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 12/23/21.
//

import SwiftUI
import PMDataTypes

struct MemberDiesView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var memberId: ID = ""
    @State private var dateDied = Date()
    @State private var comment = ""
    @State private var orphans = [ID]()
    @State private var removalState: MemberDiesState = .enteringData
    @State private var showingSheet = false

    var body: some View {
        Form {
            Text("Member died").font(.title)
            ChooseMemberView(caption: "Member who died:", memberId: $memberId)
            DateSelectionView(caption: "Date of death:", date: $dateDied)
            EditTextView(caption: "Comment:", text: $comment)
            HStack {
                Spacer()
                SolidButton(text: "Check changes", action: checkChanges)
                    .disabled(memberId.count <= 0)
                Spacer()
            }.padding()
        }
        .sheet(isPresented: $showingSheet) {
            MemberDiesSheet(memberId: $memberId,
                            dateDied: $dateDied,
                            comment: $comment,
                            orphans: $orphans,
                            removalState: $removalState,
                            showingSheet: $showingSheet)
                .environmentObject(document)
        }
    }
    
    func checkChanges() {
        let household = document.household(byId: document.member(byId: memberId).household)
        let householdStatus = household.statusOf(member: memberId)
        if householdStatus == .spouse {
            removalState = .removeSpouse
            NSLog("rem state spouse \(removalState)")
            showingSheet = true
            return
        }
        if householdStatus == .other {
            removalState = .removeDependent
            NSLog("rem state other \(removalState)")
            showingSheet = true
            return
        }
        //member is head of household
        if household.spouse != nil {
            //head has spouse, who becomes head
            removalState = .removeHead
            showingSheet = true
            return
        }
        //no spouse, so dependents would become orphans
        orphans = household.others
        removalState = .prospectiveOrphans
        showingSheet = true
        return
    }
}

struct MemberDiesView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDiesView()
            .environmentObject(mockDocument)
    }
}
