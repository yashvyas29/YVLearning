//
//  MyUnitCurveAnimation.swift
//  YVLearning
//
//  Created by Yash Vyas on 22-04-2026.
//

import SwiftUI

/// A `CustomAnimation` that drives its timing through any `UnitCurve`.
/// The curve maps normalised time → normalised value, so swapping the
/// curve instance is all that is needed to switch between easeInOut,
/// circularEaseOut, or an entirely custom Bézier.
@available(iOS 17.0, *)
struct MyUnitCurveAnimation: CustomAnimation {
    var curve: UnitCurve
    var duration: TimeInterval

    func animate<V: VectorArithmetic>(
        value: V, time: TimeInterval, context: inout AnimationContext<V>
    ) -> V? {
        if time <= duration {
            value.scaled(by: curve.value(at: time / duration))
        } else {
            nil
        }
    }

    func velocity<V: VectorArithmetic>(
        value: V, time: TimeInterval, context: AnimationContext<V>
    ) -> V? {
        value.scaled(by: curve.velocity(at: time / duration) / duration)
    }
}
