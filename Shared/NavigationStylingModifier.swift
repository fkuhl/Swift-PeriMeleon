//
//  NavigationStylingModifier.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 5/29/21.
//

import SwiftUI

/**
 This represents a misguided effort to make the code compile under strict macOS, rather
 than macCatalyst (because I thought the doc-based framework might work better outside
 macCatalyst).
 In any case, as of Swift 5.5 the "modifiers inside conditiional compile block" syntax is supported.
 */

///You can't put modifiers inside conditiional compile blocks!
struct NavigationStylingModifier: ViewModifier {
    var title: String
    var hide: Bool = false
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        return content
            .navigationBarTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hide)
        #else
        return content
        #endif
    }
}
