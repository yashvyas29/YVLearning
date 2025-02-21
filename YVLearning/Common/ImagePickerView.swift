//
//  ImagePickerView.swift
//  YVLearning
//
//  Created by Yash Vyas on 12-02-2025.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {

    var selectedImage: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = context.coordinator
        return imagePickerVC
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Used to update UIKit class after state changes to SwiftUI
    }

    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(context: self)
    }
}

final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let context: ImagePickerView

    init(context: ImagePickerView) {
        self.context = context
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        context.selectedImage(image)
    }
}
