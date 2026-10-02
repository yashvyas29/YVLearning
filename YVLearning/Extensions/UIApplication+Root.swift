//
//  UIApplication+Root.swift
//  YVLearning
//
//  Created by Yash Vyas on 17-09-2026.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene
        let keyWindow = windowScene?.windows.first(where: { $0.isKeyWindow })
        return keyWindow
    }

    var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
}
