//
//  YVCircularProgressView.swift
//  YVLearning
//
//  Created by Yash Vyas on 07/08/22.
//

import SwiftUI

struct YVCircularProgressView: View {
    let color: Color
    let progress: CGFloat

    @Binding var showProgress: Bool
    var backgroundColor: Color = .clear
    var lineWidth = 30.0

    var body: some View {
        Circle()
            .trim(from: 0, to: showProgress ? progress : 0)
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(Angle(degrees: -90))
            .overlay(Circle()
                .stroke(backgroundColor == .clear ? backgroundColor : backgroundColor.opacity(0.1), lineWidth: lineWidth))
            .animation(.linear(duration: 1), value: showProgress)
            .padding()
    }
}

struct YVCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YVCircularProgressView(color: .red, progress: 0.5, showProgress: .constant(true), backgroundColor: .gray)
            .padding()
    }
}
