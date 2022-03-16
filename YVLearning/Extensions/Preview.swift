//
//  Preview.swift
//  YVLearning
//
//  Created by Yash Vyas on 16/03/22.
//

import SwiftUI

extension ColorScheme {
    var previewName: String {
        String(describing: self).capitalized
    }
}

extension ContentSizeCategory {
    static let smallestAndLargest = [allCases.first!, allCases.last!]

    var previewName: String {
        self == Self.smallestAndLargest.first ? "Small" : "Large"
    }
}

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

extension View {
    func previewAsComponent() -> some View {
        ComponentPreview(component: self)
    }

    func previewAsScreen() -> some View {
        ScreenPreview(screen: self)
    }
}

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        var viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController,
                                    context: Context) {
            // We don’t need to write any update code in this case.
        }
    }

    func asPreview() -> some View {
        Preview(viewController: self)
    }
}
