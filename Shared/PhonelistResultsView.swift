//
//  PhonelistResultsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistResultsView: View {
    @EnvironmentObject var model: Model
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance
    @State private var resultsAsData = Data()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Phone").font(.caption)
                    Text("Email").font(.caption)
                    ForEach(members) {
                        Text(memberName(member: $0)).font(.body)
                        Text(phone(member: $0)).font(.body)
                        Text(email(member: $0)).font(.body)
                    }
                }
            }.padding()
        }
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
            let maker = PhonelistMaker(model: model)
            resultsAsData = maker.make(from: members).data(using: .utf8)!
            queryResults.setCSV(results: resultsAsData)
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up").font(.body)
        }.padding(20)
    }
    
    ///Copy to pasteboard
    private var macShare: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                let maker = PhonelistMaker(model: model)
                let pasteboard = UIPasteboard.general
                pasteboard.string = maker.make(from: members)
            }) {
                Image(systemName: "arrow.up.doc.on.clipboard").font(.body)
            }.padding(.top, 20).padding(.bottom, 5).padding(.trailing, 20)
            Text("Copy to paste buffer. Paste into file.").font(.body).italic()
                .padding(.trailing, 20)
        }
    }

    private func memberName(member: Member) -> String {
        return member.displayName()
    }

    private func phone(member: Member) -> String {
        if !nugatory(member.mobilePhone) { return member.mobilePhone! }
        let household = model.household(byId: member.household)
        if let address = household.address, !nugatory(address.homePhone) {
            return address.homePhone!
        } else {
            return ""
        }
    }

    private func email(member: Member) -> String {
        if !nugatory(member.eMail) { return member.eMail! }
        let household = model.household(byId: member.household)
        if let address = household.address, !nugatory(address.email) {
            return address.email!
        } else {
            return ""
        }
    }
}


struct PhonelistResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistResultsView(title: "Phone list",
                             members: .constant([mockMember1, mockMember2]),
                             showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
