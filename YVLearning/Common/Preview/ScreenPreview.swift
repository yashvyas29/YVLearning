//
//  ScreenPreview.swift
//  YVLearning
//
//  Created by Yash Vyas on 16/03/22.
//

import SwiftUI

struct ScreenPreview<Screen: View>: View {
    var screen: Screen

    var body: some View {
        ForEach(values: deviceNames) { device in
            ForEach(values: ColorScheme.allCases) { scheme in
                NavigationView {
                    self.screen
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
                .previewDevice(PreviewDevice(rawValue: device))
                .colorScheme(scheme)
                .previewDisplayName("\(scheme.previewName): \(device)")
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }

    private var deviceNames: [String] {
        [
            "iPhone 13 mini",
//            "iPhone 13",
//            "iPhone 13 Pro Max",
//            "iPad (9th generation)",
//            "iPad Pro (12.9-inch) (5th generation)",
            "iPod touch (7th generation)"
        ]
    }
}
