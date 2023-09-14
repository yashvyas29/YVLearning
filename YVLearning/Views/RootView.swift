//
//  RootView.swift
//  YVLearning
//
//  Created by Yash Vyas on 17/02/22.
//

import SwiftUI

struct RootView: View {
    @State private var isActive: Bool = false
//    @State private var isActive: RootPresentationMode = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Hello, World!")
                NavigationLink(
//                destination: ContentView1(rootIsActive: self.$isActive),
                    destination: ContentView1(),
                    isActive: self.$isActive
                ) {
                    Text("Go to Hello, World #1!")
                }
            }
//            .isDetailLink(false)
            .navigationBarTitle("Root")
        }
        .navigationViewStyle(.stack)
        .environment(\.rootPresentationMode, self.$isActive)
    }
}

struct ContentView1: View {
//    @Binding var rootIsActive: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Hello, World #1!")
            NavigationLink(
//            destination: ContentView2(rootIsActive: self.$rootIsActive)
                destination: ContentView2()
            ) {
                Text("Go to Hello, World #2!")
            }
            Button(action: {
//                self.rootIsActive = false
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Pop")
            })
        }
//        .isDetailLink(false)
        .navigationBarTitle("One", displayMode: .inline)
    }
}

struct ContentView2: View {
//    @Binding var rootIsActive: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Hello, World #2!")
            NavigationLink(
//            destination: ContentView3(rootIsActive: self.$rootIsActive)
                destination: ContentView3()
            ) {
                Text("Go to Hello, World #3!")
            }
            Button(action: {
                //                self.rootIsActive = false
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Pop")
            })
        }
//        .isDetailLink(false)
        .navigationBarTitle("Two", displayMode: .inline)
    }
}

struct ContentView3: View {
//    @Binding var rootIsActive: Bool
    @Environment(\.rootPresentationMode) var rootPresentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Hello, World #3!")
            Button(action: {
//                self.rootIsActive = false
                rootPresentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Pop to root")
            })
        }.navigationBarTitle("Three", displayMode: .inline)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
