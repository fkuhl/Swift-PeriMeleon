//
//  DocumentPicker.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/21/21.
//

///https://capps.tech/blog/read-files-with-documentpicker-in-swiftui
///https://sarunw.com/posts/how-to-save-export-image-in-mac-catalyst/
//////Assumes at least iOS 14.

#if targetEnvironment(macCatalyst)
import UIKit
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    ///Why a Binding? because when SwiftUI creates this struct, the URL isn't known.
    ///Must be computed later.
    @Binding var fileURL: URL
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileURL: fileURL)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>)
        -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forExporting: [fileURL])
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    // MARK: - UIDocumentPickerDelegate
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            NSLog("Error deleting file: \(error.localizedDescription)")
        }
    }
}
#endif
