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
    @State var minimumAgeText = "14"
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    @State var minimumAge = 14
    @State var ageBorderColor = Color.black

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
                    TextField("Min age:", text: $minimumAgeText)
                        .font(.body)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(ageBorderColor, width: 2)
                        .onChange(of: minimumAgeText) { newValue in
                            NSLog("onChange \(newValue)")
                            if let age = Int(minimumAgeText) {
                                minimumAge = age
                                ageBorderColor = Color.black
                            } else {
                                ageBorderColor = Color.orange
                            }
                        }
                    Spacer()
                }
                HStack(alignment: .center, spacing: 20) {
                    Text("Text: \(minimumAgeText)").font(.body)
                    Spacer()
                    Text("Int val: \(minimumAge)").font(.body)
                }
            }
            Section {
                HStack {
                    Spacer()
                    RoundedOutlineButton(text: "Run Query", action: {
                        NSLog("run query, age >= \(minimumAge)")
                        members = document.content.filterMembers {
                            let isActive = $0.status.isActive()
                            let residency = (includeResident && $0.resident)
                                                || (includeNonResident && !$0.resident)
                            let gender = (includeMen && $0.sex == .MALE) ||
                                (includeWomen && $0.sex == .FEMALE)
                            let isOfAge = $0.age(asOf: Date()) >= minimumAge
                            return isActive && residency && gender && isOfAge
                        }
                        self.showingResults = true
                    }).padding()
                    .disabled(minimumAge < 0 || minimumAge > 90)
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
