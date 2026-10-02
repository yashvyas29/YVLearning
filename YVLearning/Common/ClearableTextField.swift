//
//  ClearableTextField.swift
//  YVLearning
//
//  Created by Yash Vyas on 18-05-2026.
//

import SwiftUI

struct ClearableTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
