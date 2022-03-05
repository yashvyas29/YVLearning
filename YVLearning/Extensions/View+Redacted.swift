//
//  View+Redacted.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import SwiftUI

@available(iOS 14.0, *)
extension View {
    @ViewBuilder
    func redacted(if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? .placeholder : [])
    }
}
