//
//  UINavigationView.swift
//  YVLearning
//
//  Created by Yash Vyas on 13/02/22.
//

import UIKit
import SwiftUI

final class UINavigationView: UIViewControllerRepresentable, ObservableObject {
    typealias UIViewControllerType = UINavigationController

    private let navVC: UINavigationController

    init<Content: View>(rootView: Content) {
        navVC = UINavigationController(rootViewController: UIHostingController(rootView: rootView))
    }

    func show<Content: View>(_ view: Content) {
        navVC.show(UIHostingController(rootView: view), sender: nil)
    }

    func showDetail<Content: View>(_ view: Content) {
        navVC.showDetailViewController(UIHostingController(rootView: view), sender: nil)
    }

    func pop(animated: Bool = true) {
        navVC.popViewController(animated: animated)
    }

    func dismiss(animated: Bool = true) {
        navVC.dismiss(animated: animated, completion: nil)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        navVC.delegate = context.coordinator
        return navVC
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

extension UINavigationView {
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: UINavigationView

        init(_ parent: UINavigationView) {
            self.parent = parent
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
