//
//  GrayCapsuleButtonStyle.swift
//  YVLearning
//
//  Created by Yash Vyas on 30/03/22.
//

import SwiftUI

struct GrayCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                Capsule().fillStroke(fillColor: .systemGray5, strokeColor: .red, lineWidth: 2)
            )
            .minimumScaleFactor(0.4)
            .scaledToFit()
    }
}

struct GrayCapsuleButtonStylePreviews: PreviewProvider {
    static var previews: some View {
        Button {
            debugPrint("GrayCapsuleButton pressed.")
        } label: {
            Text("Gray Capsule Button")
        }
        .buttonStyle(.grayCapsuleStyle)
        .padding()
        .previewAsComponent()
    }
}

extension ButtonStyle where Self == GrayCapsuleButtonStyle {
    static var grayCapsuleStyle: Self { .init() }
}
