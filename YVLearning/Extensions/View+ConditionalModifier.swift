//
//  View+ConditionalModifier.swift
//  YVLearning
//
//  Created by Yash Vyas on 29/03/22.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func apply<Content: View>(
        @ViewBuilder _ transform: (Self) -> Content
    ) -> some View {
        transform(self)
    }
}
