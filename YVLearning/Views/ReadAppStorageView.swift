//
//  ReadAppStorageView.swift
//  YVLearning
//
//  Created by Yash Vyas on 08/03/22.
//

import SwiftUI

@available(iOS 14.0, *)
struct ReadAppStorageView: View {
    @AppStorage("name") var name: String = "Yash"
    var body: some View {
        NavigationView {
            HStack(spacing: 10) {
                Text("Name: \(name)")
                    .font(.system(.title))
                NavigationLink {
                    WriteAppStorageView()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("Read App Storage")
        }
        .navigationViewStyle(.stack)
        .accentColor(.red)
    }
}

@available(iOS 14.0, *)
struct ReadAppStorageView_Previews: PreviewProvider {
    static var previews: some View {
        ReadAppStorageView()
    }
}
