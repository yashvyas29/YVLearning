//
//  iOSSlider.swift
//  YVLearning
//
//  Created by Yash Vyas on 17/03/22.
//

import SwiftUI

struct iOSSlider: View {
    @Binding var percentage: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.red)
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100))
            }
            .frame(maxHeight: 60)
            .cornerRadius(15)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.percentage = min(max(0, CGFloat(value.location.x / geometry.size.width * 100)), 100)
                }))
        }
    }
}

struct iOSSlider_Previews: PreviewProvider {
    static var previews: some View {
        iOSSlider(percentage: .constant(10))
    }
}
