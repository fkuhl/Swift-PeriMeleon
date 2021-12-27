//
//  MoveToHouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/22/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct MoveToHouseholdView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var droppedOnNew = false
    
    var body: some View {
        HStack {
            memberList
            householdList
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Moves To Another Household")
            }
        }
    }
    
    private var memberList: some View {
        VStack {
            Text("Drag member to move:").font(.caption).italic()
            Form {
                ForEach(document.activeMembers) { member in
                    Text(member.fullName())
                        .onDrag { NSItemProvider(object: member.id as NSString) }
                }
            }
        }
    }
    
    private var householdList: some View {
        VStack {
            Text("To new or existing household:").font(.caption).italic()
        Form {
                Text("New household").bold().italic()
                .onDrop(of: ["public.text"],
                        isTargeted: $droppedOnNew,
                        perform: dropOnNew)
            Text("") //trying to isolate "new" drop target
            List {
                ForEach(document.activeHouseholds) { household in
                    Text(household.name ?? "[none]")
                }
                .onInsert(of: ["public.text"], perform: dropOnExisting)
            }
        }
        }
    }
    
    private func dropOnNew(_ items: [NSItemProvider], _ at: CGPoint) -> Bool {
        if let item = items.first {
            _ = item.loadObject(ofClass: String.self) { memberId, _ in
                DispatchQueue.main.async {
                    NSLog("Dropped \(memberId ?? "[nil]") on new")
                }
            }
        }
        return true
    }
    
    private func dropOnExisting(at index: Int, _ items: [NSItemProvider]) {
        for item in items {
            _ = item.loadObject(ofClass: String.self) { memberId, _ in
                DispatchQueue.main.async {
                    NSLog("member\(memberId ?? "[nil]") dropped on \(document.activeHouseholds[index].name ?? "[none]")")
                }
            }
        }
    }

}

struct MoveToHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdView()
            .environmentObject(mockDocument)
            .previewLayout(.fixed(width: 896, height: 414))
    }
}
