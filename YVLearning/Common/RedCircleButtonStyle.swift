//
//  RedCapsuleButtonStyle.swift
//  YVLearning
//
//  Created by Yash Vyas on 29/03/22.
//

import SwiftUI

struct RedCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
            configuration.label
                .font(.headline)
        }
        .padding(25)
        .background(Circle().fill(Color.red))
        .foregroundColor(.yellow)
        .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct RedCircleButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: { print("Pressed") }) {
            Text("Add Item")
        }
        .buttonStyle(.redCircleStyle)
        .padding()
    }
}

extension ButtonStyle where Self == RedCircleButtonStyle {
    static var redCircleStyle: Self { .init() }
}
