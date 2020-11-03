//
//  IntegerTextField.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/31/20.
//

import SwiftUI

struct IntegerTextField: View {
    var placeholder = ""
    @Binding var value: Int
    var min = Int.min
    var max = Int.max
    @State private var ageBorderColor = Color.accentColor
    @State private var fieldText = ""
    
    var body: some View {
        TextField(placeholder, text: $fieldText)
            .font(.body)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(ageBorderColor, width: 1)
            .onChange(of: fieldText) { newValue in
                if let age = Int(fieldText), age >= min, age <= max {
                    value = age
                    ageBorderColor = Color.accentColor
                } else {
                    ageBorderColor = Color.orange
                }
            }
    }
}

struct IntegerTextField_Previews: PreviewProvider {
    static var previews: some View {
        IntegerTextField(placeholder: "Type something",
                         value: .constant(0))
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
