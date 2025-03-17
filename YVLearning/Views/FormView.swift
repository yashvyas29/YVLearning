//
//  FormView.swift
//  YVLearning
//
//  Created by Yash Vyas on 14-02-2025.
//

import SwiftUI

struct FormView: View {

    @State private var formState = FormState()

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
            Stepper("Stepper", value: $formState.stepperValue)
            Slider(value: $formState.sliderValue)
            Spacer(minLength: 10)
            VStack(alignment: .leading) {
                HStack {
                    TextField("TextField", text: $formState.text, onEditingChanged: { editing in
                        print("onEditingChanged")
                        print(editing)
                    }, onCommit: {
                        print("onCommit")
                    })
                    .onReceive(formState.text.publisher, perform: { _ in
                        print("onReceive of TextField")
                        print(formState.text)
                        let textLimit = 10
                        if formState.text.count >= textLimit {
                            formState.text = String(formState.text.prefix(textLimit))
                        }
                    })
                    .textFieldStyle(.roundedBorder)
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                    if !formState.text.isEmpty {
                        Button {
                            print("Save Text")
                            formState.validate()
                        } label: {
                            Image(systemName: "checkmark.square.fill")
                                .font(.largeTitle)
                        }
                    } else {
                        Text("*")
                            .foregroundColor(.accent)
                    }
                }

                let errors = formState.errorMessages
                if errors.hasValue {
                    ForEach(values: errors!) {
                        Text($0)
                            .foregroundColor(.accent)
                    }
                }
            }
            if #available(iOS 14.0, *) {
                TextEditor(text: $formState.textDetails)
                    .border(.gray.opacity(0.2))
                    .frame(height: 200)
                    .onChange(of: formState.textDetails) { _ in
                        print("onChange of TextEditor")
                        print(formState.textDetails)
                    }
                Toggle("Toggle", systemImage: "togglepower", isOn: $formState.isOn)
                    .toggleStyle(.switch)
                ProgressView()
                    .progressViewStyle(.linear)
                DisclosureGroup("DisclosureGroup", content: { Text("Expanded") })
            }
        }
    }
}

extension FormView {
    struct FormState {
        @FormFieldValidation(rule: .name(fieldName: "Text"))
        var text = ""
        var textDetails = ""
        var isOn = false
        var stepperValue = 0
        var sliderValue = 0.0
        var errorMessages: [String]?

        mutating func validate() {
            let error = $text
            guard error.hasValue else {
                errorMessages = nil
                return
            }
            errorMessages = [error!]
        }
    }
}

#Preview {
    FormView()
}
