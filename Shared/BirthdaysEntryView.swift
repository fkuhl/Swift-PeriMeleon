//
//  MemberQueryEntryView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct BirthdaysEntryView: View {
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Hun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    @Binding var document: PeriMeleonDocument
    @Binding var selectedMonth: Int
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    
    var body: some View {
        Form {
            Section {
                Text("Find active members with birthdays in:").font(.title).padding(30)
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Picker(selection: $selectedMonth,
                           label: Text("Choose month:").font(.body)) {
                        ForEach(0 ..< months.count) {
                            Text(months[$0]).font(.body)
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    SolidButton(text: "Run Query", action: {
                        NSLog("run query")
                        members = document.content.filterMembers {
                            if !$0.isActive() { return false }
                            if let dob = $0.dateOfBirth {
                                let calendar = Calendar.current
                                return calendar.component(.month, from: dob) == selectedMonth + 1
                            } else { return false }
                        }
                        withAnimation(.easeInOut(duration: editAnimationDuration)) {
                            self.showingResults = true
                        }
                    })
                    Spacer()
                }.padding()
            }
        }
    }
}

struct BirthdaysEntryView_Previews: PreviewProvider {
    
    static var previews: some View {
        BirthdaysEntryView(document: mockDocument,
                           selectedMonth: .constant(10),
                           members: .constant([Member]()),
                           showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
