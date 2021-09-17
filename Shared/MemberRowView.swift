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
    @EnvironmentObject var document: PeriMeleonDocument
    var memberId: ID

    var body: some View {
        NavigationLink(destination: MemberView(memberId: memberId)
                        .environmentObject(document)) {
            Text(document.nameOf(member: memberId))
                .font(.body)
        }
    }
}
