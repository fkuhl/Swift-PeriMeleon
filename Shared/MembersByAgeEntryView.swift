//
//  MembersByAgeEntryView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MembersByAgeEntryView: View {
    @Binding var document: PeriMeleonDocument
    @Binding var asOfDate: Date
    @Binding var comparison: Comparison
    @Binding var age: Int
    @Binding var sort: ResultSort
    @Binding var members: [Member]
    @Binding var showingResults: Bool
    
    var body: some View {
        Form {
            Section {
                Text("Query Active Members by Age").font(.title).padding(30)
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Picker(selection: $comparison, label: Text("Ordering:").font(.body)) {
                        ForEach(Comparison.allCases, id: \.self) {
                            Text($0.rawValue).font(.body).tag($0)
                        }
                    }
                    IntegerTextField(placeholder: "age", value: $age, min: 1, max: 150)
                    Text("years").font(.body)
                    Spacer()
                    Text("As of:").font(.body)
                    DatePicker(selection: $asOfDate, in: ...Date(), displayedComponents: .date) {
                        Text("").font(.body)
                    }
                    Spacer()
                }
                HStack(spacing: 20) {
                    Spacer()
                    Text("Sorted by:").font(.body)
                    Picker(selection: $sort, label: Text("")) {
                        ForEach (ResultSort.allCases, id: \.self) {
                            //Don't forget the tag!
                            Text($0.rawValue).font(.body).tag($0)
                        }
                    }.frame(maxWidth: 100)/*.background(Color.yellow)*/
                    Spacer()
                }
//            }
//            Section {
                HStack {
                    Spacer()
                    SolidButton(text: "Run Query", action: {
                        NSLog("run query")
                        members = document.content.filterMembers {
                            $0.status.isActive() && $0.dateOfBirth != nil &&
                            comparison.comparator($0.age(asOf: asOfDate), age)
                        }
                        members.sort(by: sort.comparator)
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

struct MembersByAgeEntryView_Previews: PreviewProvider {
    
    static var previews: some View {
        MembersByAgeEntryView(document: mockDocument,
                              asOfDate: .constant(Date()),
                              comparison: .constant(.lessThan),
                              age: .constant(21),
                              sort: .constant(.name),
                              members: .constant([Member]()),
                              showingResults: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Preview")
    }
}
