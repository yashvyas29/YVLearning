//
//  UINavigationHandler.swift
//  YVLearning
//
//  Created by Yash Vyas on 14/02/22.
//

import SwiftUI
import UIKit

protocol UINavigationHandler {
    var navigationController: UINavigationController { get }
    func set<Content: View>(_ views: Content)
    func show<Content: View>(_ view: Content)
    func showDetail<Content: View>(_ view: Content)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func dismiss(animated: Bool)
}

extension UINavigationHandler {

    var navigationController: UINavigationController {
        UINavigationController()
    }

    func set<Content: View>(_ views: [Content]) {
        let viewControllers = views.compactMap { UIHostingController(rootView: $0) }
        navigationController.setViewControllers(viewControllers, animated: true)
    }

    func show<Content: View>(_ view: Content) {
        navigationController.show(UIHostingController(rootView: view), sender: nil)
    }

    func showDetail<Content: View>(_ view: Content) {
        navigationController.showDetailViewController(UIHostingController(rootView: view), sender: nil)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }

    func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated, completion: nil)
    }
}
