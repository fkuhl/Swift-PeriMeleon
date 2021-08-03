//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes


struct MembersView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var allOrActive = 0
    @State private var members: [Member] = []
    @State private var filterText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker(selection: $allOrActive,
                           label: Text("What's in a name?"),
                           content: {
                            Text("Active Members").tag(0)
                            Text("All Members").tag(1)
                           })
                        .pickerStyle(SegmentedPickerStyle())
                        
                }.padding()
                ///Dividing all and active members into 2 views lessens the work (and delay) when changing
                ///from one to the other.
                if allOrActive == 0 {
                    SomeMembersView(allOrActive: 0)
                } else {
                    SomeMembersView(allOrActive: 1)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text(allOrActive == 0 ? "Active Members" : "All Members")
                        })})
        }
        .environmentObject(document)
        //.debugPrint("MembersView \(model.members.count) members")
    }
}



struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
        MembersView()
            .padding()
            .background(Color(.systemBackground))
            .previewLayout(.fixed(width: 1024, height: 768))
            .environmentObject(mockDocument)
    }
}
