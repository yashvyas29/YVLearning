//
//  AnimationView.swift
//  YVLearning
//
//  Created by Yash Vyas on 20-04-2026.
//

import SwiftUI

// MARK: - Transaction Key

private struct AvatarTappedKey: TransactionKey {
    static let defaultValue = false
}

@available(iOS 17.0, *)
extension Transaction {
    var avatarTapped: Bool {
        get { self[AvatarTappedKey.self] }
        set { self[AvatarTappedKey.self] = newValue }
    }
}

// MARK: - Scoped Animation Modifier

@available(iOS 17.0, *)
struct ScoppedAnimationModifierView<Content: View>: View {
    var content: Content
    @Binding var selected: Bool

    var body: some View {
        content
            .animation(.smooth) {
                $0.shadow(radius: selected ? 12 : 8)
            }
            .animation(.bouncy) {
                $0.scaleEffect(selected ? 1.5 : 1.0)
            }
            .onTapGesture {
                selected.toggle()
            }
    }
}

// MARK: - Scoped Transaction Modifier

@available(iOS 17.0, *)
struct ScoppedTransactionModifierView<Content: View>: View {
    var content: Content
    @Binding var selected: Bool

    var body: some View {
        content
            .transaction {
                $0.animation = $0.avatarTapped ? .bouncy : .smooth
            } body: {
                $0.scaleEffect(selected ? 1.5 : 1.0)
            }
            .onTapGesture {
                withTransaction(\.avatarTapped, true) {
                    selected.toggle()
                }
            }
    }
}

// MARK: - Custom Linear Animation (MyLinearAnimation)

/// Demonstrates `MyLinearAnimation`: a hand-rolled `CustomAnimation` that
/// interpolates linearly over a fixed duration.
@available(iOS 17.0, *)
struct CustomLinearView: View {
    @Binding var active: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.blue)
            .frame(width: 56, height: 56)
            .offset(x: active ? 100 : -100)
            .animation(Animation(MyLinearAnimation(duration: 1.0)), value: active)
            .onTapGesture { active.toggle() }
    }
}

// MARK: - UnitCurve Animations

/// A single labelled row used by `UnitCurveView`.
@available(iOS 17.0, *)
private struct UnitCurveRow: View {
    let label: String
    let color: Color
    let animation: Animation
    let active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 56, height: 56)
                .offset(x: active ? 100 : -100)
                .animation(animation, value: active)
        }
    }
}

/// Shows three `MyUnitCurveAnimation` instances backed by different `UnitCurve` values:
/// a built-in ease-in-out, a circular ease-out, and a custom Bézier.
@available(iOS 17.0, *)
struct UnitCurveView: View {
    @Binding var active: Bool

    // Custom Bézier: fast departure, gradual arrival.
    // P1 = (0.9, 0.0), P2 = (0.9, 1.0) in unit time-progress space.
    private let fastDeparture = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.9, y: 0.0),
        endControlPoint: UnitPoint(x: 0.9, y: 1.0)
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UnitCurveRow(
                label: "easeInOut (built-in UnitCurve)",
                color: .orange,
                animation: Animation(MyUnitCurveAnimation(curve: .easeInOut, duration: 0.7)),
                active: active
            )
            UnitCurveRow(
                label: "circularEaseOut (built-in UnitCurve)",
                color: .red,
                animation: Animation(MyUnitCurveAnimation(curve: .circularEaseOut, duration: 0.7)),
                active: active
            )
            UnitCurveRow(
                label: "Fast-departure (UnitCurve.bezier)",
                color: .purple,
                animation: Animation(MyUnitCurveAnimation(curve: fastDeparture, duration: 0.7)),
                active: active
            )
        }
        .onTapGesture { active.toggle() }
    }
}

// MARK: - Spring Animations

/// A single labelled row used by `SpringView`.
@available(iOS 17.0, *)
private struct SpringRow: View {
    let label: String
    let color: Color
    let spring: Spring
    let active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 56, height: 56)
                .offset(x: active ? 100 : -100)
                .animation(.spring(spring), value: active)
        }
    }
}

/// Shows three `Spring` instances with varying `duration` and `bounce`.
/// `bounce: 0` gives a critically damped spring; higher values add overshoot.
@available(iOS 17.0, *)
struct SpringView: View {
    @Binding var active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SpringRow(
                label: "Gentle   Spring(duration: 0.6, bounce: 0.1)",
                color: .green,
                spring: Spring(duration: 0.6, bounce: 0.1),
                active: active
            )
            SpringRow(
                label: "Bouncy   Spring(duration: 0.5, bounce: 0.6)",
                color: .mint,
                spring: Spring(duration: 0.5, bounce: 0.6),
                active: active
            )
            SpringRow(
                label: "Stiff    Spring(duration: 0.3, bounce: 0.0)",
                color: .teal,
                spring: Spring(duration: 0.3, bounce: 0.0),
                active: active
            )
        }
        .onTapGesture { active.toggle() }
    }
}

// MARK: - Main View

@available(iOS 17.0, *)
struct AnimationView: View {
    @State private var selectedScopedAnim = false
    @State private var selectedTransaction = false
    @State private var activeLinear = false
    @State private var activeUnitCurve = false
    @State private var activeSpring = false

    var body: some View {
        List {
            AnimationSection("Scoped .animation modifier (tap bear)") {
                ScoppedAnimationModifierView(
                    content: Image(systemName: "teddybear").font(.system(size: 60)),
                    selected: $selectedScopedAnim
                )
            }
            AnimationSection("Scoped .transaction modifier (tap bear)") {
                ScoppedTransactionModifierView(
                    content: Image(systemName: "teddybear").font(.system(size: 60)),
                    selected: $selectedTransaction
                )
            }
            AnimationSection("MyLinearAnimation — custom CustomAnimation (tap)") {
                CustomLinearView(active: $activeLinear)
            }
            AnimationSection("MyUnitCurveAnimation — UnitCurve-backed (tap)") {
                UnitCurveView(active: $activeUnitCurve)
            }
            AnimationSection("Spring — built-in Spring struct (tap)") {
                SpringView(active: $activeSpring)
            }
        }
        .navigationTitle("Animations")
    }
}

// MARK: - Section Helper

@available(iOS 17.0, *)
private struct AnimationSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        Section(title) {
            content
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    NavigationStack {
        AnimationView()
    }
}
