//
//  QueryResults.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/24/20.
//

import SwiftUI

class QueryResults: ObservableObject {
    @Published var toBeShared: [PMActivityItemSource]
    
    public static let sharedInstance = QueryResults()
    
    init() {
        toBeShared = [PMActivityItemSource(value: .text(""))]
    }
    
    func set(results: ResultsType) {
        toBeShared = [PMActivityItemSource(value: results)]
    }
}

enum ResultsType {
    case text(String)
    case csv(Data)
}
