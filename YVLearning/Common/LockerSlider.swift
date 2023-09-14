//
//  YVSlider.swift
//  YVLearning
//
//  Created by Yash Vyas on 17/03/22.
//

import SwiftUI

struct LockerSlider<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    // MARK: - Value
    // MARK: Private
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    private let step: V.Stride

    private let length: CGFloat    = 50
    private let lineWidth: CGFloat = 2

    @State private var ratio: CGFloat   = 0
    @State private var startX: CGFloat?

    // MARK: - Initializer
    init(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride = 1) {
        _value  = value

        self.bounds = bounds
        self.step   = step
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: length / 2)
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)))

                // Thumb
                Circle()
                    .foregroundColor(.yellow)
                    .frame(width: length, height: length)
                    .offset(x: (proxy.size.width - length) * ratio)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ updateStatus(value: $0, proxy: proxy) })
                        .onEnded { _ in startX = nil })
            }
            .frame(height: length)
            .overlay(overlay)
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged({ update(value: $0, proxy: proxy) }))
            .onAppear {
                ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
            }
        }
    }

    // MARK: Private
    private var overlay: some View {
        RoundedRectangle(cornerRadius: (length + lineWidth) / 2)
            .stroke(Color.yellow, lineWidth: lineWidth)
            .frame(height: length + lineWidth)
    }

    // MARK: - Function
    // MARK: Private
    private func updateStatus(value: DragGesture.Value, proxy: GeometryProxy) {
        guard startX == nil else { return }

        let delta = value.startLocation.x - (proxy.size.width - length) * ratio
        startX = (length < value.startLocation.x && 0 < delta) ? delta : value.startLocation.x
    }

    private func update(value: DragGesture.Value, proxy: GeometryProxy) {
        guard let xAxis = startX else { return }
        startX = min(length, max(0, xAxis))

        var point = value.location.x - xAxis
        let delta = proxy.size.width - length

        // Check the boundary
        if point < 0 {
            startX = value.location.x
            point = 0

        } else if delta < point {
            startX = value.location.x - delta
            point = delta
        }

        // Ratio
        var ratio = point / delta

        // Step
        if step != 1 {
            let unit = CGFloat(step) / CGFloat(bounds.upperBound)

            let remainder = ratio.remainder(dividingBy: unit)
            if remainder != 0 {
                ratio -= CGFloat(remainder)
            }
        }

        self.ratio = ratio
        self.value = V(bounds.upperBound) * V(ratio)
    }
}

struct LockerSlider_Previews: PreviewProvider {
    static var previews: some View {
        LockerSlider(value: .constant(10), in: 0...100)
    }
}
