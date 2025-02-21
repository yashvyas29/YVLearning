//
//  UICardView.swift
//  YVLearning
//
//  Created by Yash Vyas on 14-02-2025.
//

import SwiftUI

class UICardView: UIView {

    let label: UILabel

    init() {
        label = UILabel()
        super.init(frame: .zero)

        label.text = "Hello, World!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SwiftUICardView: UIViewRepresentable {

    var text: String

    func makeUIView(context: Context) -> UICardView {
        .init()
    }
    
    func updateUIView(_ uiView: UICardView, context: Context) {
        print(#function)
        uiView.label.text = text
    }
}

struct CardContentView: View {

    @State var text = "Hello, World!"

    var body: some View {
        VStack {
            SwiftUICardView(text: text)
            Button("Tap me") {
                text = "Hello, SwiftUI!"
            }
        }
    }
}

#Preview {
    CardContentView()
}
