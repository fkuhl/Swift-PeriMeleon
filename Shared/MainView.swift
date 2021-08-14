//
//  MainView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var selection = 0
    
    var body: some View {
        NavigationView {
            Sidebar().frame(width: 320)
                .toolbar(content: {
                            ToolbarItem(placement: .principal, content: {
                                Text("PeriMeleōn").font(.largeTitle)
                            })})

//            Color(.red)
            Image("sinaiticus")
                .resizable(resizingMode: .tile)
                //.aspectRatio(contentMode: .fill)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                //.frame(maxWidth: 500)
        }
        .environmentObject(document)
    }
}
