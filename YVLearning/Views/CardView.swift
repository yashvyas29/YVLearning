//
//  CardView.swift
//  YVLearning
//
//  Created by Yash Vyas on 10-02-2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct CardView<HeaderView: View, Content: View, FooterView: View>: View {
    private let headerView: HeaderView
    @ViewBuilder private let content: () -> Content
    private let footerView: FooterView

    init(
        headerView: HeaderView,
        @ViewBuilder content: @escaping () -> Content,
        footerView: FooterView
    ) {
        self.headerView = headerView
        self.content = content
        self.footerView = footerView
    }

    @ViewBuilder var icon: some View {
        if true {
            Text("Icon")
        } else {
            Image(systemName: "globe")
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            headerView
                .frame(height: 64)
                .frame(maxWidth: .infinity)
                .background(.gray)
                .foregroundStyle(.white)
                .font(.title)
            content()
            Button("Button", action: {})
            icon
            footerView
                .buttonStyle(.plain)
                .frame(height: 64)
                .frame(maxWidth: .infinity)
                .background(.gray)
                .foregroundStyle(.white)
                .font(.title)
        }
        .clipShape(.rect(cornerSize: .init(width: 24, height: 24)))
        .shadow(radius: 8)
        .padding()
    }
}
