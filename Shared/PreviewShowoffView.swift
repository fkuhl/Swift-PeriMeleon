//
//  PreviewShowoffView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/21/20.
//

/**
 See PreviewProviderModifier.swift
 */
#if DEBUG
import SwiftUI

struct PreviewShowoffView: View {
    var body: some View {
        Label("Hello, World!", systemImage: "hand.wave.fill")
    }
}

struct PreviewShowoffView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewShowoffView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}

#endif
