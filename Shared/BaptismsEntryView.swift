//
//  BaptismsEntryView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 6/3/21.
//

import SwiftUI
import PMDataTypes

struct BaptismsEntryView: View {
    @Binding var document: PeriMeleonDocument
    @Binding var earliest: Date
    @Binding var latest: Date
    @Binding var members: [Member]
    @Binding var showingResults: Bool

    var body: some View {
        Form {
            HStack {
                Spacer()
                Text("Earliest date:").frame(width: 150).font(.body)
                DatePicker(selection: $earliest, in: ...Date(), displayedComponents: .date) {
                    Text("").font(.body)
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Latest date:").frame(width: 150).font(.body)
                DatePicker(selection: $latest, in: ...Date(), displayedComponents: .date) {
                    Text("").font(.body)
                }
                Spacer()
            }
            HStack {
                Spacer()
                SolidButton(text: "Run Query", action: runQuery)
                Spacer()
            }.padding()
        }
    }
    
    func runQuery() {
        NSLog("run query")
        members = document.filterMembers {
            if let recordedBaptism = $0.baptism, recordedBaptism.count > 0 {
                if let baptismalDate = findDate(raw: recordedBaptism) {
                    return earliest <= baptismalDate && baptismalDate <= latest
                }
            }
            return false
        }
        withAnimation(.easeInOut(duration: editAnimationDuration)) {
            self.showingResults = true
        }
    }
}

// MARK: - Preview

struct BaptismsEntryView_Previews: PreviewProvider {
    static var previews: some View {
        BaptismsEntryView(document: mockDocument,
                          earliest: .constant(Date()),
                          latest: .constant(Date()),
                          members: .constant([Member]()),
                          showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")    }
}

// MARK: - Parsing

//https://developer.apple.com/documentation/foundation/nsregularexpression?changes=_9

/**
 The strategy for recognizing baptisms is to attempt to extract a date
 */
fileprivate let anythingZeroOrMore = ".*"
fileprivate let digit = "[0-9]"
fileprivate let optDigit = digit + "?"
fileprivate let monthDayYearPattern = try! NSRegularExpression(pattern:
    anythingZeroOrMore + "(" + digit + digit
    + "/" + digit + digit
    + "/" + digit + digit + optDigit + optDigit + ")" + anythingZeroOrMore,
                                                          options: [])

fileprivate let monthDayYearFormatter = makeMonthDayYearFormatter()
fileprivate func findDate(raw: String) -> Date? {
    //if raw.count > 1 { NSLog("checking '\(raw)'")}
    let rawRange = NSRange(raw.startIndex..., in: raw)
    let matches = monthDayYearPattern.matches(in: raw, options: [], range: rawRange)
    if matches.count < 1 { return nil }
    //grab just the part between the "capturing parens"
    let dateString = extract(from: raw, range: matches[0].range(at: 1))
    //NSLog("found '\(dateString)'")
    return monthDayYearFormatter.date(from: dateString)
}

fileprivate func makeMonthDayYearFormatter() -> DateFormatter {
    NSLog("making date formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "MM/dd/YYYY"
    return dateFormatter
}

///Extract part of a UTF-8 String
fileprivate func extract(from: String, range: NSRange) -> String {
    //Create string indices (UTF-8, recall) from the range
    let startIndex = from.index(from.startIndex, offsetBy: range.location)
    let endIndex = from.index(startIndex, offsetBy: range.length)
    return String(from[startIndex..<endIndex])
}
