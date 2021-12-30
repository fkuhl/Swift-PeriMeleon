//
//  MoveToHouseholdTarget.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/28/21.
//

import SwiftUI

struct MoveToHouseholdTarget: View {
    @EnvironmentObject var document: PeriMeleonDocument
    var household: NormalizedHousehold
    @State private var droppedOnSpouse = false
    @State private var droppedOnOther = false
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(household.name ?? "[none]",
                        isExpanded: $isExpanded) { form }
    }
    
    private var form: some View {
        Form {
            EditDisplayView(caption: "Head:", message: document.nameOf(member: household.head))
            if let spouse = household.spouse {
                EditDisplayView(caption: "Spouse:", message: document.nameOf(member: spouse))
            } else {
                EditDisplayView(caption: "No spouse", message: "")
                    .onDrop(of: ["public.text"],
                            isTargeted: $droppedOnSpouse,
                            perform: dropOnSpouse)
            }
            EditDisplayView(caption: "Number of others", message: "\(household.others.count)")
                .onDrop(of: ["public.text"],
                        isTargeted: $droppedOnOther,
                        perform: dropOnOther)
        }.frame(height: 200)
    }

    private func dropOnSpouse(_ items: [NSItemProvider], _ at: CGPoint) -> Bool {
        if let item = items.first {
            _ = item.loadObject(ofClass: String.self) { memberId, _ in
                DispatchQueue.main.async {
                    NSLog("Dropped \(memberId ?? "[nil]") on spouse")
                }
            }
        }
        return true
    }
    
    private func dropOnOther(_ items: [NSItemProvider], _ at: CGPoint) -> Bool {
        if let item = items.first {
            _ = item.loadObject(ofClass: String.self) { memberId, _ in
                DispatchQueue.main.async {
                    NSLog("Dropped \(memberId ?? "[nil]") on other")
                }
            }
        }
        return true
    }
}

struct MoveToHouseholdTarget_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdTarget(household: mockHousehold1)
            .environmentObject(mockDocument)
            .previewLayout(.fixed(width: 896, height: 414))
    }
}
