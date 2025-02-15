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
        Sidebar().frame(width: 320)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    Text(document.fileName)//.font(.largeTitle)
                })})
        Image("sinaiticus")
            .resizable(resizingMode: .tile)
    }
}
