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
    @ObservedObject var model: Model = .shared
    var memberId: ID
    @Binding var changeCount: Int

    var body: some View {
        NavigationLink(destination: MemberView(memberId: memberId,
                                               changeCount: $changeCount)
                        .environmentObject(model)) {
            Text(model.nameOf(member: memberId))
                .font(.body)
        }
        //.debugPrint("MRV \(member.fullName())")
    }
}
