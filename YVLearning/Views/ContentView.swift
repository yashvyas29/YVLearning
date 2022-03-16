//
//  ContentView.swift
//  YVLearning
//
//  Created by Yash Vyas on 12/02/22.
//

import MapKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        NumberButtonView(number: 1)
    }
}

struct NumberButtonView: View {
    @EnvironmentObject private var navView: UINavigationView
    let number: Int

    var body: some View {
        Button("Show Screen \(number)") {
            navView.show(
                NumberButtonView(number: number+1)
            )
        }
    }
}

struct UINavigationShowView<Content: View>: View {
    let content: Content
    init(_ content: Content) {
        self.content = content
    }
    var body: some View {
        content
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewAsScreen()
    }
}
