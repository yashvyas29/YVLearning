//
//  YVGaugeView.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/08/22.
//

import SwiftUI

struct YVGaugeView: View {
    @State var showProgress: Bool = false
    var lineWidth = 25.0

    @State var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Group {
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
            .frame(width: 360)
            Group {
                circularView(color: .black, background: .gray, progress: 0.1)
                circularView(color: .pink, progress: 0.2, from: 0.1)
                circularView(color: .gray, progress: 0.3, from: 0.2)
                circularView(color: .purple, progress: 0.4, from: 0.3)
                circularView(color: .orange, progress: 0.5, from: 0.4)
                circularView(color: .yellow, progress: 0.6, from: 0.5)
                circularView(color: .blue, progress: 0.7, from: 0.6)
                circularView(color: .green, progress: 0.8, from: 0.7)
                circularView(color: .red, progress: 0.9, from: 0.8)
                circularView(color: .systemTeal, progress: 1, from: 0.9)
            }
            .frame(width: 280)
            VStack {
                Text("\(progress, specifier: "%.1f")")
                Button("Animate") {
                    if progress > 0.9 {
                        progress = 0
                    } else {
                        progress = 1
                    }
                    showProgress.toggle()
                }
            }
            .foregroundColor(.red)
            .font(.title)

            YVCircularProgressView(color: .red, progress: $progress, backgroundColor: .black, lineWidth: lineWidth)
                .frame(width: 200)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        if progress <= 0.9 {
                            progress += 0.1
                        } else {
                            timer.invalidate()
                        }
                    }
                }
        }
        .padding()
        .onAppear {
            showProgress.toggle()
        }
    }

    private func circularView(color: Color, background: Color = .clear, progress: CGFloat, from: CGFloat = 0) -> some View {
        Circle()
            .trim(from: from, to: showProgress ? progress : 0)
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
