//
//  QueryResults.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/24/20.
//

import SwiftUI

class QueryResults: ObservableObject {
    @Published var toBeShared: [Any]
    
    public static let sharedInstance = QueryResults()
    
    init() {
        toBeShared = [""]
    }
}
