//
//  UseImagePickerView.swift
//  YVLearning
//
//  Created by Yash Vyas on 12-02-2025.
//

import SwiftUI

struct UseImagePickerView: View {

    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 44) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
            }

            Button(action: {
                isImagePickerPresented = true
            }, label: {
                HStack {
                    Image(systemName: "photo.badge.plus.fill")
                    Text("Pick Image")
                }
            })
            .buttonStyle(.borderless)
            .font(.title)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView { image in
                selectedImage = image
                isImagePickerPresented = false
            }
        }
    }
}
