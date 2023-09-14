//
//  ListRowSeparatorModifier.swift
//  YVLearning
//
//  Created by Yash Vyas on 20/02/22.
//

import SwiftUI

extension View {
    func listRowSeparator(insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                          background: Color = .white) -> some View {
        modifier(ListRowSeparatorModifier(insets: insets, background: background))
    }
}

struct ListRowSeparatorModifier: ViewModifier {

    static let defaultListRowHeight: CGFloat = 44

    var insets: EdgeInsets
    var background: Color

    func body(content: Content) -> some View {
        content
            .padding(insets)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: Self.defaultListRowHeight)
            .listRowInsets(EdgeInsets())
            .overlay(
                VStack {
                    HStack {}
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(background)
                    Spacer()
                    HStack {}
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(background)
                }
                    .padding(.top, -1)
            )
    }
}
