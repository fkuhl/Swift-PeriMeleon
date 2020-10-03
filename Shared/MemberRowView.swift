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
    var item: Member
    
    var body: some View {
        NavigationLink(destination: MemberView(member: item)) {
            Text(item.fullName())
                .font(.body)
        }
    }
}

//struct MemberRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        //MemberRowView(item: member1)
//    }
//}
