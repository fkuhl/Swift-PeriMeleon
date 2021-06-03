//
//  BirthdaysResultsView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct BirthdaysResultsView: View {
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance

    var body: some View {
        VStack {
            HStack {
                clearButton
                Spacer()
                Text(title).font(.title)
                Spacer()
                #if targetEnvironment(macCatalyst)
                macShare
                #else
                iosShare
                #endif
            }
            HStack {
                Spacer()
                Text(makeBirthdaysResult(members: self.members))
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Spacer()
        }.padding()
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
        }
    }
    
    private var clearButton: some View {
        Button(action: {
            self.members = []
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                self.showingResults = false
            }
        }) {
            Text("Clear").font(.body)
        }.padding(20)
    }
    
    ///Bring up share sheet
    private var iosShare: some View {
        Button(action: {
            queryResults.setText(results: makeBirthdaysResult(members: self.members))
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up").font(.body)
        }.padding(20)
    }
    
    ///Copy to pasteboard
    private var macShare: some View {
        Button(action: {
            let pasteboard = UIPasteboard.general
            pasteboard.string = makeBirthdaysResult(members: self.members)
        }) {
            Image(systemName: "arrow.up.doc.on.clipboard").font(.body)
        }.padding(20)
    }
}

struct BirthdaysResultsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let mocks = [mockMember1, mockMember2]
        return BirthdaysResultsView(title: "This is The Title",
                                    members: .constant(mocks),
                                    showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}

fileprivate func makeBirthdaysResult(members: [Member]) -> String {
    let reps = members.compactMap { member -> String? in
        let nameRep = "\(member.firstName()) \(member.familyName)"
        if let dob = member.dateOfBirth {
            let calendar = Calendar.current
            return "\(nameRep) (\(calendar.component(.day, from: dob)))"
        } else { return nil }
    }
    return reps.joined(separator: ", ")
}
