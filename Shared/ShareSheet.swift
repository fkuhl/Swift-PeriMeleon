//
//  ShareSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/24/20.
//

//https://developer.apple.com/forums/thread/123951

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType] = [.postToWeibo,
                                                            .postToVimeo,
                                                            .postToFlickr,
                                                            .postToTwitter,
                                                            .postToFacebook,
                                                            .postToTencentWeibo]
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
