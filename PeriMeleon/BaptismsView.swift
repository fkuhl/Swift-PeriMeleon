//
//  BaptismsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 6/5/21.
//

import SwiftUI
import PMDataTypes

struct BaptismsView: View {
    private static let titleDateFormatter = makeTitleDateFormatter()
    @State var earliest: Date = yearEarlier()
    @State var latest: Date = Date()
    @State var members = [Member]()
    @State var showingResults = false

    var body: some View {
        VStack {
            if !showingResults {
                BaptismsEntryView(earliest: $earliest,
                                  latest: $latest,
                                  members: $members,
                                   showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                BaptismsResultsView(title: resultsTitleString,
                                     members: $members,
                                     showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Baptisms between dates:")
            }
        }
    }
    
    private var resultsTitleString: String {
        "\(members.count) Baptism\(members.count == 1 ? "" : "s") Between "
            + "\(Self.titleDateFormatter.string(from: earliest))"
        + " and \(Self.titleDateFormatter.string(from: latest))"
    }
}

fileprivate func yearEarlier() -> Date {
    let components = DateComponents(year: -1)
    return Calendar.current.date(byAdding: components, to: Date())!
}

fileprivate func makeTitleDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}

struct BaptismsView_Previews: PreviewProvider {
    static var previews: some View {
        BaptismsView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
            .environmentObject(mockDocument)
    }
}
