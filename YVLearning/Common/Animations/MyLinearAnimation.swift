//
//  MyLinearAnimation.swift
//  YVLearning
//
//  Created by Yash Vyas on 20-04-2026.
//

import SwiftUI

@available(iOS 17.0, *)
struct MyLinearAnimation: CustomAnimation {
    var duration: TimeInterval

    func animate<V: VectorArithmetic>(
        value: V, time: TimeInterval, context: inout AnimationContext<V>
    ) -> V? {
        if time <= duration {
            value.scaled(by: time / duration)
        } else {
            nil  // animation has finished
        }
    }

    func velocity<V: VectorArithmetic>(
        value: V, time: TimeInterval, context: AnimationContext<V>
    ) -> V? {
        value.scaled(by: 1.0 / duration)
    }
}
