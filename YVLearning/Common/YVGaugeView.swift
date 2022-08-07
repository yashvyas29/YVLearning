//
//  YVGaugeView.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/08/22.
//

import SwiftUI

struct YVGaugeView: View {
    @State var showProgress: Bool = false
    var lineWidth = 30.0

    var body: some View {
        ZStack {
            Group {
//                YVCircularProgressView(color: .systemTeal, progress: 1, showProgress: $showProgress, backgroundColor: .gray)
                circularView(color: .systemTeal, background: .gray, progress: 1)
                circularView(color: .red, progress: 0.9)
                circularView(color: .green, progress: 0.8)
                circularView(color: .blue, progress: 0.7)
                circularView(color: .yellow, progress: 0.6)
                circularView(color: .orange, progress: 0.5)
                circularView(color: .purple, progress: 0.4)
                circularView(color: .gray, progress: 0.3)
                circularView(color: .pink, progress: 0.2)
                circularView(color: .black, progress: 0.1)
            }
            Button("Animate") {
                showProgress.toggle()
            }
            .foregroundColor(.red)
            .font(.largeTitle)
        }
        .padding()
        .onAppear {
            showProgress.toggle()
        }
    }

    private func circularView(color: Color, background: Color = .clear, progress: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: showProgress ? progress : 0)
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(Angle(degrees: -90))
            .overlay(Circle()
                .stroke(background == .clear ? background : background.opacity(0.1), lineWidth: lineWidth))
            .animation(.linear(duration: 1), value: showProgress)
            .padding()
    }
}

struct YVGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        YVGaugeView()
    }
}
