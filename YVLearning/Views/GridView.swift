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
        GridItem(.flexible())
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
                if #available(iOS 16.0, *) {
                    VStack {
                        Grid(horizontalSpacing: 1, verticalSpacing: 0) {
                            GridRow {
                                ForEach(0..<5) { _ in
                                    Color.red
                                }
                            }
                            Divider()
                                .frame(height: 10)
                                .background(Color.green)
                            GridRow {
                                Color.blue
                                    .gridCellColumns(5)
                            }
                        }
                        Grid {
                            GridRow {
                                Text("Hello")
                                Image(systemName: "globe")
                            }
                            Divider()
                                .gridCellUnsizedAxes(.horizontal)
                            GridRow {
                                Image(systemName: "hand.wave")
                                Text("World")
                            }
                        }
                    }
                    .frame(height: 320)
                }
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
