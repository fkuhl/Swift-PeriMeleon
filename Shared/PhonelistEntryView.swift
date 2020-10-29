//
//  PhonelistEntryView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 10/28/20.
//

import SwiftUI
import PMDataTypes

struct PhonelistEntryView: View {
    @Binding var document: PeriMeleonDocument
    @Binding var includeResident: Bool
    @Binding var includeNonResident: Bool
    @Binding var includeMen: Bool
    @Binding var includeWomen: Bool
    @Binding var minimumAge: Int
    @Binding var members: [Member]
    @Binding var showingResults: Bool

    var body: some View {
        Form {
            Text("Query Members by Status").font(.title).padding(30)
            Section {
                HStack(alignment: .center, spacing: 20) {
                    CompactToggleView(isOn: $includeResident, label: "Include residents")
                    Spacer()
                    CompactToggleView(isOn: $includeNonResident, label: "Include non-residents")
                    Spacer()
                }
                HStack(alignment: .center, spacing: 20) {
                    CompactToggleView(isOn: $includeMen, label: "Include men")
                    Spacer()
                    CompactToggleView(isOn: $includeWomen, label: "Include women")
                    Spacer()
                }
                HStack(alignment: .center, spacing: 20) {
                    Text("Minimum age to include:")
                    TextField("Min age:", value: $minimumAge, formatter: NumberFormatter())
                }
            }
            Section {
                Button(action: {
                    NSLog("run query")
//                    members = document.content.filterMembers {
//                        $0.status == self.desiredStatus &&
//                            ((self.includeResident && $0.resident)
//                                || (self.includeNonResident && !$0.resident))
//                    }
                    self.showingResults = true
                }) {
                    Text("Query").font(.title)
                }.padding(20)
            }.disabled(minimumAge < 0 || minimumAge > 90)
        }
    }
}

struct PhonelistEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistEntryView(document: mockDocument,
                           includeResident: .constant(true),
                           includeNonResident: .constant(false),
                           includeMen:  .constant(true),
                           includeWomen: .constant(true),
                           minimumAge: .constant(25),
                           members: .constant([Member]()),
                           showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
