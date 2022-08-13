//
//  YVCircularProgressView.swift
//  YVLearning
//
//  Created by Yash Vyas on 07/08/22.
//

import SwiftUI

struct YVCircularProgressView: View {
    let color: Color
    @Binding var progress: CGFloat
    var backgroundColor: Color = .clear
    var lineWidth = 30.0

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(Angle(degrees: -90))
            .overlay(Circle()
                .stroke(backgroundColor == .clear ? backgroundColor : backgroundColor.opacity(0.1), lineWidth: lineWidth))
            .animation(.linear(duration: 1), value: progress)
            .padding()
    }
}

struct YVCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YVCircularProgressView(color: .red, progress: .constant(0.5), backgroundColor: .gray)
            .padding()
    }
}
