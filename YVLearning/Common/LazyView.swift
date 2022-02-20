//
//  LazyView.swift
//  YVLearning
//
//  Created by Yash Vyas on 21/02/22.
//

import SwiftUI

struct LazyView<Content: View>: View {
    private let content: () -> Content

    init(_ content: @autoclosure @escaping () -> Content) {
        self.content = content
    }

    var body: Content {
        content()
    }
}
