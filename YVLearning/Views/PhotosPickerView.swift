//
//  PhotoPickerView.swift
//  YVLearning
//
//  Created by Yash Vyas on 12-02-2025.
//

import PhotosUI
import SwiftUI

@available(iOS 16.0, *)
struct PhotosPickerView: View {
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil

    var body: some View {
        PhotosPicker(
            selection: $photoPickerItem,
            matching: .images,
            label: {
                Label("Pick Photo", systemImage: "photo.badge.plus")
                    .font(.title)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .font(.title)

            }
        )
        .onChange(of: photoPickerItem) { newValue in
            Task {
                selectedImage = try? await newValue?.loadTransferable(type: Image.self)
            }
        }
    }
}
