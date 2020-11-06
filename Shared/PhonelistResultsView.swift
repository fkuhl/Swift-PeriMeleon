//
//  PhonelistResultsView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistResultsView: View {
    @Binding var document: PeriMeleonDocument
    var title: String
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State private var showingShareSheet = false
    @ObservedObject private var queryResults = QueryResults.sharedInstance

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack {
            Text(title).font(.title)
            HStack {
                Button(action: {
                    self.members = []
                    withAnimation(.easeInOut(duration: editAnimationDuration)) {
                        self.showingResults = false
                    }
                }) {
                    Text("Clear").font(.body)
                }.padding(20)
                Spacer()
                Button(action: {
                    let maker = PhonelistMaker(document: document)
                    let csv = maker.make(from: members).data(using: .utf8)!
                    queryResults.set(results: .csv(csv))
                    NSLog("results: \(csv.count) char")
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").font(.body)
                }.padding(20)
            }
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                    Text("Member").font(.caption)
                    Text("Phone").font(.caption)
                    Text("Email").font(.caption)
                    ForEach(members, id: \.id) {
                        Text(memberName(member: $0)).font(.body)
                        Text(phone(member: $0)).font(.body)
                        Text(email(member: $0)).font(.body)
                    }
                }
            }.padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: queryResults.toBeShared)
//                .debugPrint("queryResults element has \((queryResults.toBeShared[0] as! NSString).length)")
        }
    }

    private func memberName(member: Member) -> String {
        return member.displayName()
    }

    private func phone(member: Member) -> String {
        if !nugatory(member.mobilePhone) { return member.mobilePhone! }
        let household = document.content.household(byId: member.household)
        if let address = household.address, !nugatory(address.homePhone) {
            return address.homePhone!
        } else {
            return ""
        }
    }

    private func email(member: Member) -> String {
        if !nugatory(member.eMail) { return member.eMail! }
        let household = document.content.household(byId: member.household)
        if let address = household.address, !nugatory(address.email) {
            return address.email!
        } else {
            return ""
        }
    }
}


struct PhonelistResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistResultsView(document: mockDocument,
                             title: "Phone list",
                             members: .constant([mockMember1, mockMember2]),
                             showingResults: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
