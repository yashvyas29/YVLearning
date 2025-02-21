//
//  FormView.swift
//  YVLearning
//
//  Created by Yash Vyas on 14-02-2025.
//

import SwiftUI

struct FormView: View {
    @State private var text = ""
    @State private var textDetails = ""
    @State private var isOn = false
    @State private var stepperValue = 0
    @State private var sliderValue = 0.0

    var body: some View {
        Form {
            Text("Text")
                .bold()
                .italic()
                .underline()
                .font(.title)
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
            Button("Button") {}
                .buttonStyle(.borderless)
            Divider()
            Stepper("Stepper", value: $stepperValue)
            Slider(value: $sliderValue)
            Spacer(minLength: 10)
            HStack {
                TextField("TextField", text: $text, onEditingChanged: { editing in
                    print("onEditingChanged")
                    print(editing)
                }, onCommit: {
                    print("onCommit")
                })
                .onReceive(text.publisher, perform: { _ in
                    print("onReceive of TextField")
                    print(text)
                    let textLimit = 10
                    if text.count >= textLimit {
                        text = String(text.prefix(textLimit))
                    }
                })
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    UITextField.appearance().clearButtonMode = .whileEditing
                }
                if !text.isEmpty {
                    Button {
                        print("Save Text")
                    } label: {
                        Image(systemName: "checkmark.square.fill")
                            .font(.largeTitle)
                    }
                }
            }
            if #available(iOS 14.0, *) {
                TextEditor(text: $textDetails)
                    .border(.gray.opacity(0.2))
                    .frame(height: 200)
                    .onChange(of: textDetails) { _ in
                        print("onChange of TextEditor")
                        print(textDetails)
                    }
                Toggle("Toggle", systemImage: "togglepower", isOn: $isOn)
                    .toggleStyle(.switch)
                ProgressView()
                    .progressViewStyle(.linear)
                DisclosureGroup("DisclosureGroup", content: { Text("Expanded") })
            }
        }
    }
}

#Preview {
    FormView()
}
