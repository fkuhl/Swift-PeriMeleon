//
//  MemberView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 12/23/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI


struct MembersView: View {
    @Binding var document: PeriMeleonDocument
    @State private var allOrActive = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $allOrActive,
                       label: Text("What's in a name?"),
                       content: {
                        Text("All Members").tag(0)
                        Text("Active Members").tag(1)
                }).pickerStyle(SegmentedPickerStyle())
                List {
                    ForEach(allOrActive == 0 ? document.content.members : document.content.activeMembers, id: \.id) {
                        MemberRowView(document: $document, member: $0)
                    }
                }
            }
//            .alert(isPresented: $dataFetcher.showingAlert) {
//                Alert(title: Text("Failed to fetch Members"),
//                      message: Text("\(dataFetcher.fetchError?.reason ?? "")\n\(dataFetcher.fetchError?.errorString ?? "")"),
//                      dismissButton: .default(Text("OK")))
//            }
            .navigationBarTitle(allOrActive == 0 ? "All Members" : "Active Members")
        }
    }
}



//struct MembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        MembersView(memberFetcher: MemberFetcher.mockedInstance)
//    }
//}
