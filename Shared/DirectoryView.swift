//
//  DirectoryView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/22/21.
//

import SwiftUI
import PMDataTypes

struct DirectoryView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var temporaryURL = URL(fileURLWithPath: "") //placeholder
    @State private var results = [""]
    @ObservedObject private var queryResults = QueryResults.sharedInstance

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()
                Text("Directory").font(.title)
                Spacer()
#if targetEnvironment(macCatalyst)
                macShare
#else
                iosShare
#endif
            }
            ScrollView {
                ForEach(results, id: \.self) { line in
                    HStack {
                        Text(line)
                        Spacer()
                    }
                }.padding()
            }
        }
        .onAppear() {
            let maker = DirectoryMaker(document: document)
            results = maker.make()
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
                    let suggestedFileName = "\(dateFormatter.string(from: Date()))-directory.txt"
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

struct DirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryView()
    }
}
