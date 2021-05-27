//
//  ExplainError.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/25/21.
//

import Foundation

/**
 Decode DecodingError for error messages.
 
 DecodingError (thrown by decoding JSON) contains lots of info.
 This returns some strings that can make an intelligible error message.
 - Parameter error: the error to be decoded
 - Returns: (type of error encountered, coding stack if any, more detailed debug description)
 */
func explain(error: DecodingError) -> (String, String, String) {
    let debugDescription: String
    let explanation: (String, String)
    switch error {
    case .dataCorrupted(let context):
        debugDescription = context.debugDescription
        explanation = explain(context: context)
    case .keyNotFound(let key, let context):
        debugDescription = "\(key.stringValue) was not found, \(context.debugDescription)"
        explanation = explain(context: context)
    case .typeMismatch(let type, let context):
        debugDescription = "\(type) was expected, \(context.debugDescription)"
        explanation = explain(context: context)
    case .valueNotFound(let type, let context):
        debugDescription = "no value was found for \(type), \(context.debugDescription)"
        explanation = explain(context: context)
    @unknown default:
        return ("", "", "")
    }
    return (debugDescription, explanation.0, explanation.1)
}

fileprivate func explain(context: DecodingError.Context) -> (String,String) {
    let codingPathElements = context.codingPath.map{$0.stringValue}
    let path = codingPathElements.joined(separator: ", ")
    var nsDebugDescription = ""
    if let underlying = context.underlyingError as NSError? {
        nsDebugDescription = underlying.userInfo["NSDebugDescription"] as? String ?? ""
    }
    return (path, nsDebugDescription)
}
