//
//  Shape+StrokeFill.swift
//  YVLearning
//
//  Created by Yash Vyas on 30/03/22.
//

import SwiftUI

extension Shape {
    func fillStroke(fillColor: Color, strokeColor: Color, lineWidth: CGFloat = 1) -> some View {
        self.stroke(strokeColor, lineWidth: lineWidth)
            .background(self.fill(fillColor))
    }
}

extension InsettableShape {
    func fillStroke(fillColor: Color, strokeColor: Color, lineWidth: CGFloat = 1) -> some View {
        self.strokeBorder(strokeColor, lineWidth: lineWidth)
            .background(self.fill(fillColor))
    }
}
