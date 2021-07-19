//
//  MainView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/22/21.
//

import SwiftUI

struct MainView: View {
    @State private var selection = 0
    
    var body: some View {
        NavigationView {
            Sidebar().frame(width: 350)
//            Color(.gray)
            Image("sinaiticus")
                .resizable(resizingMode: .tile)
                //.aspectRatio(contentMode: .fill)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                //.frame(maxWidth: 500)
        }
    }
}
