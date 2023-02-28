//
//  CustomShape.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/02/23.
//

import SwiftUI

struct CustomShape: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 100)
            Trapezoid()
                .fill(Color.red)
                .frame(width: 200, height: 100)
            TrapezoidWithTopRightArcCorner()
                .fill(Color.red)
                .frame(width: 200, height: 100)
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 100)
                .cornerRadius(50, corners: [.topRight, .bottomLeft])
            Capsule()
                .fill(Color.red)
                .frame(width: 200, height: 100)
            Circle()
                .fill(Color.red)
                .frame(width: 200)
        }
    }
}

struct CustomShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomShape()
    }
}

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let horizontalOffset: CGFloat = rect.width * 0.25
            // Top Left
            path.move(to: .zero)
            // Top Right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            // Bottom Right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            // Bottom Left + horizontalOffset
            path.addLine(to: CGPoint(x: rect.minX + horizontalOffset, y: rect.maxY))
        }
    }
}

struct TrapezoidWithTopRightArcCorner: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let horizontalOffset: CGFloat = rect.width * 0.25
            // Top Left
            path.move(to: .zero)
            // Top Right to Bottom Right Arc
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                        tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
                        radius: horizontalOffset)
            // Bottom Right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            // Bottom Left + horizontalOffset
            path.addLine(to: CGPoint(x: rect.minX + horizontalOffset, y: rect.maxY))
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
