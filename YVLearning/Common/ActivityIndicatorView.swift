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
    public var configuration = { (indicator: UIActivityIndicatorView) in }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView { UIActivityIndicatorView() }
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}
