//
//  MemberRowView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/16/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MemberRowView: View {
    @Binding var document: PeriMeleonDocument
    var memberId: ID
    @Binding var changeCount: Int

    var body: some View {
        NavigationLink(destination: MemberView(document: $document,
                                               memberId: memberId,
                                               changeCount: $changeCount)) {
            Text(document.nameOf(member: memberId))
                .font(.body)
        }
        //.debugPrint("MRV \(member.fullName())")
    }
}

//struct MemberRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        //MemberRowView(item: member1)
//    }
//}
