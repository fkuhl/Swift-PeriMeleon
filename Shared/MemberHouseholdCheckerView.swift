//
//  MemberHouseholdCheckerView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 11/13/21.
//

import SwiftUI
import PMDataTypes

struct MemberHouseholdCheckerView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var temporaryURL = URL(fileURLWithPath: "") //placeholder
    @State private var results = [""]
    @State private var showingProgress = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()
                Text("Member-Household Consistency Check").font(.title)
                Spacer()
#if targetEnvironment(macCatalyst)
                macShare
#else
                iosShare
#endif
            }
            ZStack {
                ScrollView {
                    ForEach(0..<results.count, id: \.self) { index in
                        HStack {
                            Text(results[index])
                            Spacer()
                        }
                    }.padding()
                }
                if showingProgress {
                    ProgressView().scaleEffect(3.0, anchor: .center)
                }
            }
        }
        .onAppear() {
            showingProgress = true
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let checker = MemberHouseholdChecker(document: document)
                let tentativeResults = checker.check()
                DispatchQueue.main.async {
                    showingProgress = false
                    results = tentativeResults
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentExportPicker(fileURL: $temporaryURL)
        }
#else
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
        }
#endif
    }
    
    ///Bring up share sheet
    private var iosShare: some View {
        Button(action: {
            queryResults.setText(results: results.joined(separator: "\n"))
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up").font(.body)
        }.padding(20)
    }
    
    ///Export to file
    private var macShare: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                do {
                    let resultsAsData = results.joined(separator: "\n").data(using: .utf8)!
                    let fileManager = FileManager.default
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-member-household-consistency.txt"
                    temporaryURL = fileManager.temporaryDirectory.appendingPathComponent(suggestedFileName)
                    NSLog("temp URL: \(temporaryURL)")
                    try resultsAsData.write(to: temporaryURL)
                    showingDocumentPicker = true
                } catch let error {
                    NSLog("error writing temp: \(error.localizedDescription)")
                    return
                }
            }) {
                Image(systemName: "square.and.arrow.down").font(.headline)
            }.padding(.top, 20).padding(.bottom, 5).padding(.trailing, 20)
            Text("Save to file.").font(.body).italic()
                .padding(.trailing, 20)
        }
    }
}

struct MemberHouseholdCheckerView_Previews: PreviewProvider {
    static var previews: some View {
        MemberHouseholdCheckerView()
    }
}
