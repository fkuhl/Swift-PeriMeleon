//
//  SearchField.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/29/21.
//

import SwiftUI

struct SearchField: View {
    @Binding var filterText: String
    var uiUpdater: FilterUpdater
    var sortMessage: String
    @State private var showingXCircle = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(" \(sortMessage)",
                      text: $filterText,
                      onCommit: {
                        uiUpdater.updateUI(filterText: filterText)
                        showingXCircle = filterText.count > 0
                      })
                .font(.body)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            if showingXCircle {
                Button(action: clearFilter) {
                    Label("", systemImage: "xmark.circle")
                }
            }
        }.padding(.init(top: 0.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
    }
    
    private func clearFilter() {
        filterText = ""
        showingXCircle = false
        uiUpdater.updateUI(filterText: filterText)
    }
}

struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        
        SearchField(filterText: .constant(""),
                    uiUpdater: PreviewUpdater(),
                    sortMessage: "some sort")
            .padding()
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
    
    private struct PreviewUpdater: FilterUpdater {
        func updateUI(filterText: String) {
            print("filterText: \(filterText)")
        }
    }
}

protocol FilterUpdater {
    func updateUI(filterText: String)
}

