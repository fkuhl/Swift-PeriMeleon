//
//  MoveToHouseholdExistingSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/31/21.
//

import SwiftUI
import PMDataTypes

struct MoveToHouseholdExistingSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var memberId: ID
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MoveToHouseholdExistingSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoveToHouseholdExistingSheet(memberId: .constant(mockMember1.id))
            .environmentObject(mockDocument)
    }
}
