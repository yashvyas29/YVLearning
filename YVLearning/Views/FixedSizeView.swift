//
//  FixedSizeView.swift
//  YVLearning
//
//  Created by Yash Vyas on 30-04-2026.
//

import SwiftUI

@available(iOS 15.0, *)
struct FixedSizeView: View {
    var body: some View {
        // Horizontal fixed size
        VStack {
            // Both horizontal and vertical fixed size for RoundedRactangle with parent horizontal fixed size
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.red)
                .frame(idealWidth: 100, idealHeight: 100)
                .padding()
                .fixedSize()
                .frame(maxWidth: .infinity)
                .background(.green)

            // Vertical fixed size for HStack with parent horizontal fixed size for background
            HStack {
                Text("Hi")
                    .bold()
                    .frame(maxHeight: .infinity)
                    .padding()
                    .background(.red)
                Text("Yash\nVyas")
                    .bold()
                    .frame(maxHeight: .infinity)
                    .padding()
                    .background(.red)
            }
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green)

            VStack {
                Button {
                    print("Log in action")
                } label: {
                    Text("Log in")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red, in: Capsule())
                }

                Button {
                    print("Register action")
                } label: {
                    Text("Register")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red, in: Capsule())
                }

                Button {
                    print("Continue as a Guest action")
                } label: {
                    Text("Continue as a Guest")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red, in: Capsule())
                }
            }
            .padding()
            .background(.green)
        }
        .background(.blue)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        FixedSizeView()
    }
}
