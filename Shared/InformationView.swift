//
//  InformationView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 6/2/21.
//

import SwiftUI

struct InformationView: View {
    @Environment(\.horizontalSizeClass) var size
    @Environment(\.sizeCategory) var sizeCategory
    @ScaledMetric(relativeTo: .headline) var dateTitleWidth: CGFloat = 150
    @ScaledMetric(relativeTo: .body) var datumTitleWidth: CGFloat = 150
    @ScaledMetric(relativeTo: .body) var datumStringWidth: CGFloat = 70
    @Binding var document: PeriMeleonDocument

    var body: some View {
        VStack {
            header
            documentInfo
            .padding()
            Spacer()
        }
        //.navigationBarTitle("")
        .navigationBarHidden(true)
        /**
         Here you might expect a ProgressView that would appear when the library is reloaded.
         There is already a ProgressView in the view hierarchy; see DataAvailableView.
         And that one appears!
         */
    }
    
    private var header: some View {
        VStack {
            if sizeCategory.isAccessibilityCategory {
                HStack {
                    VStack(alignment: .leading) {
                        icon
                        textStack
                    }
                    .padding()
                    Spacer()
                }
            } else {
                HStack {
                    icon
                    textStack
                    Spacer()
                }
            }
            Divider().background(Color(UIColor.systemGray))
        }
    }
    
    private var icon: some View {
        Image("info-icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150)
            .cornerRadius(7)
            .padding(.leading)
    }
    
    private var textStack: some View {
        VStack(alignment: .leading) {
            Text("PeriMeleōn")
                .font(.headline)
                .padding(.bottom)
            Text("Copyright © 2021")
                .font(.caption)
            Text("TyndaleSoft LLC")
                .font(.caption)
            Text("All Rights Reserved.")
                .font(.caption)
            Text(buildAndVersion)
                .font(.caption)
                .padding(.top)
        }
    }
    
    private let buildAndVersion =
        "v \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""), " +
        "build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "")"
    
    private var documentInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                DocInfoView(caption: "Active members:", number: document.activeMembers.count)
                DocInfoView(caption: "All members:", number: document.members.count)
                DocInfoView(caption: "Active households:", number: document.activeHouseholds.count)
                DocInfoView(caption: "All households:", number: document.households.count)
            }
            Spacer()
        }
    }
}

fileprivate struct DocInfoView: View {
    var captionWidth: CGFloat = defaultCaptionWidth
    var caption: String
    var number: Int
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(caption)
                .frame(width: captionWidth, alignment: .trailing)
                .font(.caption)
            Text("\(number)")
                .frame(width: captionWidth / 2, alignment: .trailing)
                .font(.body)
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(document: mockDocument)
            .previewLayout(PreviewLayout.fixed(width: 1024, height: 768))

    }
}
