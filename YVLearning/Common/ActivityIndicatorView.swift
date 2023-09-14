//
//  ActivityIndicatorView.swift
//  YVLearning
//
//  Created by Yash Vyas on 07/03/22.
//

import SwiftUI
import UIKit

public struct ActivityIndicatorView: UIViewRepresentable {
    public var isAnimating: Bool
    public var configuration = { (_: UIActivityIndicatorView) in }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
        configuration(uiView)
    }
}
