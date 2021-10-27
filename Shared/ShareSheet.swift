//
//  ShareSheet.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/24/20.
//

//https://developer.apple.com/forums/thread/123951
//https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example

import SwiftUI

#if os(iOS)
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

class PMActivityItemSource: NSObject, UIActivityItemSource {
    private var value: ResultsType
    
    init(value: ResultsType) {
        self.value = value
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        NSLog("got placeholder")
        switch value {
        case .text(let text):
            return text
        case .csv(let data):
            return data
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        NSLog("get item")
        switch value {
        case .text(let text):
            return text
        case .csv(let data):
            return data
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Secret message"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        NSLog("activity type was \(activityType?.rawValue ?? "[nil]")")
        switch value {
        case .text:
            return "public.text"
        case .csv:
            return "public.comma-separated-values-text"
        }
    }
}
#endif
