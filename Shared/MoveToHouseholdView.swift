//
//  MoveToHouseholdView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/22/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @State private var memberId: ID = ""
    @State private var droppedOnNew = false
    @State private var showingNewSheet = false
    @State private var showingExistingSheet = false

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
        .sheet(isPresented: $showingNewSheet) {
            MoveToHouseholdNewSheet(memberId: $memberId)
                .environmentObject(document)
        }
        .sheet(isPresented: $showingExistingSheet) {
            MoveToHouseholdExistingSheet(memberId: $memberId)
                .environmentObject(document)
        }
    }
    
    private var memberList: some View {
        VStack {
            Text("Open a household, then drag member to move:").font(.caption).italic()
            Form {
                ForEach(document.activeMembers) { member in
                    if document.eligibleToMove(member: member) {
                        Text(member.fullName())
                            .onDrag { NSItemProvider(object: member.id as NSString) }
                    } else {
                        // TODO: Need a way to tell user "nope"
                        Text(member.fullName()).foregroundColor(Color.gray)
                    }
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
                        MoveToHouseholdTarget(household: household)
                    }
                }
                //.onInsert(of: ["public.text"], perform: dropOnExisting)
            }
        }
    }
    
    private func dropOnNew(_ items: [NSItemProvider], _ at: CGPoint) -> Bool {
        if let item = items.first {
            _ = item.loadObject(ofClass: String.self) { draggedId, _ in
                DispatchQueue.main.async {
                    NSLog("Dropped \(draggedId ?? "[nil]") on new")
                    if let actualId = draggedId {
                        memberId = actualId
                        showingNewSheet = true
                    }
                }
            }
        }
        return true
    }
}

struct MoveToHouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdView()
            .environmentObject(mockDocument)
            .previewLayout(.fixed(width: 896, height: 414))
    }
}
