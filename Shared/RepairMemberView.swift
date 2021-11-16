//
//  RepairMemberView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/16/21.
//

import SwiftUI
import PMDataTypes

struct RepairMemberView: View {
    @State private var memberId: ID = ""
    @State var editing = false
    
    var body: some View {
        VStack {
            if !editing {
                chooseMember
                    .transition(.move(edge: .trailing))
            } else {
                RepairMemberEditView(memberId: memberId, editing: $editing)
                    .transition(.move(edge: .trailing))
            }
            Spacer()
        }
    }
    
    private var chooseMember: some View {
        Form {
            Text("Choose member to repair").font(.title)
            Text("This is to be used only to maintain the data, i.e., to correct a problem. It is NOT to be used for any normal membership transaction. If you edit the member's household, be sure to make the Household entry consistent.").font(.headline)
            ChooseMemberView(caption: "Member to be repaired:", memberId: $memberId)
            HStack {
                Spacer()
                SolidButton(text: "Edit member", action: edit)
                    .disabled(memberId.count <= 0)
                Spacer()
            }.padding()
        }
    }
    
    private func edit() {
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.editing = true
        }
    }
}

struct RepairMemberView_Previews: PreviewProvider {
    static var previews: some View {
        RepairMemberView()
    }
}
