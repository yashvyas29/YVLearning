//
//  TextSpacingView.swift
//  YVLearning
//
//  Created by Yash Vyas on 17/03/22.
//

import SwiftUI

struct TextSpacingView: View {
    @State var letterSpacing: CGFloat = 10
    @State var lineSpacing: CGFloat = 5
    let text = "Yash\nVyas\nffi"

    var body: some View {
        VStack(spacing: 25) {
            VStack {
                Text(text)
                    .tracking(letterSpacing)
                Divider()
                    .frame(height: 1)
                    .background(Color.yellow)
                Text(text)
                    .kerning(letterSpacing)
            }
            .padding(.vertical)
            .lineSpacing(lineSpacing)
            .font(.custom("AmericanTypewriter", size: 22))
            .foregroundColor(.yellow)
            .background(Color.red)
            .border(.yellow, width: 1)
            VStack {
                Text("Current latter spacing: \(letterSpacing, specifier: "%.2f")")
                Slider(value: $letterSpacing, in: 0...100)
                    .padding(.horizontal)
                    .accentColor(.red)
                    .overlay(RoundedRectangle(cornerRadius: 50)
                        .stroke(style: .init(lineWidth: 2))
                        .foregroundColor(.yellow))
                Text("Current line spacing: \(lineSpacing, specifier: "%.2f")")
                iOSSlider(percentage: $lineSpacing)
                    .frame(height: 35)
            }
        }
        .padding()
    }
}

struct TextSpacingView_Previews: PreviewProvider {
    static var previews: some View {
        TextSpacingView()
    }
}
