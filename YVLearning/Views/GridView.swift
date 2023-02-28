//
//  GridView.swift
//  YVLearning
//
//  Created by Yash Vyas on 30/01/23.
//

import SwiftUI

@available(iOS 14.0, *)
struct GridView: View {
    let data = (1...100).map { "Item \($0)" }

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    let columns2 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let columns3 = [
        GridItem(.fixed(100)),
        GridItem(.flexible()),
    ]

    let items = 1...50

    let rows = [
        GridItem(.fixed(50)),
        GridItem(.flexible()),
        GridItem(.fixed(50))
    ]

    var body: some View {
        ScrollView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(data, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .padding(.horizontal)
                    LazyVGrid(columns: columns2, spacing: 20) {
                        ForEach(data, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .padding(.horizontal)
                    LazyVGrid(columns: columns3, spacing: 20) {
                        ForEach(data, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 300)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, alignment: .center) {
                        ForEach(items, id: \.self) { item in
                            Image(systemName: "\(item).circle.fill")
                                .font(.largeTitle)
                        }
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
