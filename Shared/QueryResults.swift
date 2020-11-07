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
    
    func setText(results: String) {
        toBeShared = [PMActivityItemSource(value: .text(results))]
    }
    
    func setCSV(results: String) {
        let data = results.data(using: .utf8)!
        toBeShared = [PMActivityItemSource(value: .csv(data))]
    }
}

enum ResultsType {
    case text(String)
    case csv(Data)
}
