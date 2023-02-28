//
//  ScrollReaderView.swift
//  YVLearning
//
//  Created by Yash Vyas on 30/01/23.
//

import SwiftUI

@available(iOS 14.0, *)
struct ScrollReaderView: View {
    let colors: [Color] = [.red, .green, .blue]

    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                Button("Jump to #8") {
                    withAnimation {
                        value.scrollTo(8, anchor: .top)
                    }
                }
                .padding()

                ForEach(0..<100) { i in
                    Text("Example \(i)")
                        .font(.title)
                        .frame(width: 200, height: 200)
                        .background(colors[i % colors.count])
                        .id(i)
                }
            }
        }
        .frame(height: 350)
    }
}

@available(iOS 14.0, *)
struct ScrollReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollReaderView()
    }
}
