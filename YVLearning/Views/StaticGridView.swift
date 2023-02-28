//
//  StaticGridView.swift
//  YVLearning
//
//  Created by Yash Vyas on 30/01/23.
//

import SwiftUI

@available(iOS 16.0, *)
struct StaticGridView: View {
    @State private var redScore = 0
    @State private var blueScore = 0

    var body: some View {
        VStack {
            Grid {
                GridRow {
                    Text("Red")

                    ForEach(0..<redScore, id: \.self) { _ in
                        Rectangle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                    }
                }

                GridRow {
                    Text("Blue")

                    ForEach(0..<blueScore, id: \.self) { _ in
                        Rectangle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .font(.title)

            Button("Add to Red") { redScore += 1 }
            Button("Add to Blue") { blueScore += 1 }

            Grid(alignment: .leading) {
                GridRow {
                    Text("Food")
                    Text("$200")
                }

                GridRow {
                    Text("Rent")
                    Text("$800")
                }

                GridRow {
                    Text("Candles")
                    Text("$3600")
                }

                Divider()

                GridRow {
//                    Text("Total")
                    Text("$4600")
                        .gridCellColumns(2)
                        .multilineTextAlignment(.trailing)
                }

                Divider()

            }
            .font(.title)
            .padding()

            Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                GridRow {
                    Image(systemName: "xmark")
                    Image(systemName: "xmark")
                    Image(systemName: "xmark")
                }

                GridRow {
                    Image(systemName: "circle")
                    Image(systemName: "xmark")
                    Image(systemName: "circle")
                }

                GridRow {
                    Image(systemName: "xmark")
                    Image(systemName: "circle")
                    Image(systemName: "circle")
                }
            }
            .font(.largeTitle)

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<8) { row in
                    GridRow {
                        ForEach(0..<8) { col in
                            if (row + col).isMultiple(of: 2) {
                                Rectangle()
                                    .fill(.black)
                            } else {
                                Rectangle()
                                    .fill(.white)
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .border(.black, width: 1)
            .padding()
        }
    }
}

@available(iOS 16.0, *)
struct StaticGridView_Previews: PreviewProvider {
    static var previews: some View {
        StaticGridView()
    }
}
