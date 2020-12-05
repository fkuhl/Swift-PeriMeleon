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
    @State var includeResident = true
    @State var includeNonResident = false
    @State var includeMen = true
    @State var includeWomen = true
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State var minimumAge = 14
    @State var ageBorderColor = Color.accentColor

    var body: some View {
        Form {
            Section {
                Text("Export Phone List").font(.title).padding(30)
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
                    Text("Minimum age to include:").font(.body)
                    IntegerTextField(placeholder: "Min age",
                                     value: $minimumAge,
                                     min: 0,
                                     max: 100)
                    Spacer()
                }
//            }
//            Section {
                HStack {
                    Spacer()
                    SolidButton(text: "Run Query", action: {
                        NSLog("run query, age >= \(minimumAge)")
                        members = document.content.filterMembers {
                            let isActive = $0.isActive()
                            let residency = (includeResident && $0.resident)
                                || (includeNonResident && !$0.resident)
                            let gender = (includeMen && $0.sex == .MALE) ||
                                (includeWomen && $0.sex == .FEMALE)
                            let isOfAge = $0.age(asOf: Date()) >= minimumAge
                            return isActive && residency && gender && isOfAge
                        }
                        withAnimation(.easeInOut(duration: editAnimationDuration)) {
                            self.showingResults = true
                        }
                    }).padding()
                    .disabled(minimumAge < 0 || minimumAge > 100)
                    Spacer()
                }
            }
        }
    }
}


struct PhonelistEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PhonelistEntryView(document: mockDocument,
                           members: .constant([Member]()),
                           showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
