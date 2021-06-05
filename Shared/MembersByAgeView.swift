//
//  MembersByAgeView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/17/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MembersByAgeView: View {
    @Binding var document: PeriMeleonDocument
    @State var asOfDate = Date()
    @State var comparison = Comparison.lessThan
    @State var age = 0
    @State var sort = ResultSort.name
    @State var members = [Member]()
    @State var showingResults = false
    
    var body: some View {
        VStack {
            if !showingResults {
                MembersByAgeEntryView(document: $document,
                                      asOfDate: $asOfDate,
                                      comparison: $comparison,
                                      age: $age,
                                      sort: $sort,
                                      members: $members,
                                      showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            } else {
                MembersByAgeResultsView(title: resultsTitle,
                                           members: $members,
                                           showingResults: $showingResults)
                    .transition(.move(edge: .trailing))
            }
            Spacer().background(Color.red)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Query Members By Age")
            }
        }
    }
    
    private var resultsTitle: String {
        "\(members.count) Active Member\(members.count == 1 ? "" : "s"), "
        + "Age \(comparison.rawValue) \(age) as of \(dateFormatter.string(from: asOfDate))"
    }
}

struct MembersByAgeView_Previews: PreviewProvider {
    static var previews: some View {
        MembersByAgeView(document: mockDocument)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}

enum Comparison: String, CaseIterable {
    case lessThan = "<"
    case lessThanOrEqualTo = "≤"
    case greaterThan = ">"
    case greaterThanOrEqualTo = "≥"
    case equals = "="
    
    var comparator: (Int, Int) -> Bool {
        switch self {
        case .lessThan:
            return { $0 < $1 }
        case .lessThanOrEqualTo:
            return { $0 <= $1}
        case .greaterThan:
            return { $0 > $1 }
        case .greaterThanOrEqualTo:
            return { $0 >= $1 }
        case .equals:
            return { $0 == $1 }
        }
    }
}

enum ResultSort: String, CaseIterable {
    case name = "Name"
    case sex = "Sex"
    case status = "Status"
    case dateOfBirth = "Date of birth"
    
    var comparator: (Member, Member) -> Bool {
        switch self {
        case .name:
            return { $0.displayName() < $1.displayName() }
        case .sex:
            return { $0.sex.rawValue < $1.sex.rawValue }
        case .status:
            return { $0.status.rawValue < $1.status.rawValue }
        case .dateOfBirth:
            return { $0.dateOfBirth ?? Date.distantPast < $1.dateOfBirth ?? Date.distantPast }
        }
    }
}
