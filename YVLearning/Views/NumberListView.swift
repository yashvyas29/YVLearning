//
//  NumberListView.swift
//  YVLearning
//
//  Created by Yash Vyas on 20/02/22.
//

import SwiftUI

struct NumberListView: View {
    let numbers = 0..<10
    var body: some View {
        List(numbers, id: \.self) { number in
            Text("\(number)")
                .padding(.leading, 16)
//                .listRowSeparator(background: .red)
        }
        .listStyle(.plain)
        .padding(.leading, -16)
    }
}

struct NumberListView_Previews: PreviewProvider {
    static var previews: some View {
        NumberListView()
    }
}
