//
//  WriteAppStorageView.swift
//  YVLearning
//
//  Created by Yash Vyas on 08/03/22.
//

import SwiftUI

@available(iOS 14.0, *)
struct WriteAppStorageView: View {
    @AppStorage("name") var name: String = "Yash"
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 25) {
            Text("Enter name:")
                .font(.system(.title))
            TextField("", text: $name)
                .padding()
                .frame(height: 40)
                .background(RoundedRectangle(cornerRadius: 20).stroke(.red, lineWidth: 2))
                .font(.system(.headline))
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .foregroundColor(.red)
        .navigationTitle("Write App Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 14.0, *)
struct WriteAppStorageView_Previews: PreviewProvider {
    static var previews: some View {
        WriteAppStorageView()
    }
}
