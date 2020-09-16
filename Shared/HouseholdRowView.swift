//
//  HouseholdRowView.swift
//  PeriMeleon (iOS)
//
//  Created by Frederick Kuhl on 9/2/20.
//

import SwiftUI
import PMDataTypes

struct HouseholdRowView: View {
    @Binding var item: Household
    
    var body: some View {
        TextField("name:", text: $item.head.familyName).font(.body)
    }
}

//struct HouseholdRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        HouseholdRowView()
//    }
//}
