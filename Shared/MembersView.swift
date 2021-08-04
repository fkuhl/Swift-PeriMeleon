//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

enum AllOrActive: Hashable {
    case all
    case active
}

struct MembersView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var allOrActive = AllOrActive.active
    @State private var filterText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Picker(selection: $allOrActive,
                           label: Text("What's in a name?"),
                           content: {
                            Text("Active Members").tag(AllOrActive.active)
                            Text("All Members").tag(AllOrActive.all)
                           })
                        .pickerStyle(SegmentedPickerStyle())
                        
                }.padding()
                ///Dividing all and active members into 2 views lessens the work (and delay) when changing
                ///from one to the other.
                switch allOrActive {
                case .active:
                    SomeMembersView(allOrActive: .active)
                case .all:
                    SomeMembersView(allOrActive: .all)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            Text(allOrActive == .active ? "Active Members" : "All Members")
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
