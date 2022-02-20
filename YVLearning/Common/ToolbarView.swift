//
//  ToolbarView.swift
//  YVLearning
//
//  Created by Yash Vyas on 21/02/22.
//

import SwiftUI
import UIKit

struct Toolbar: UIViewRepresentable {
    typealias UIViewType = UIToolbar
    var items: [UIBarButtonItem]
    var toolbar: UIToolbar

    init(items: [UIBarButtonItem]) {
        self.toolbar = UIToolbar()
        self.items = items
    }

    func makeUIView(context: UIViewRepresentableContext<Toolbar>) -> UIToolbar {
        toolbar.setItems(self.items, animated: true)
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        return toolbar
    }

    func updateUIView(_ uiView: UIToolbar, context: UIViewRepresentableContext<Toolbar>) {
    }

    func makeCoordinator() -> Toolbar.Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIToolbarDelegate, UIBarPositioning {
        var toolbar: Toolbar
        var barPosition: UIBarPosition

        init(_ toolbar: Toolbar) {
            self.toolbar = toolbar
            self.barPosition = .bottom
        }

        private func position(for: UIToolbar) -> UIBarPosition {
            return .bottom
        }
    }
}
