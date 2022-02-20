//
//  NumberFormLinkView.swift
//  YVLearning
//
//  Created by Yash Vyas on 21/02/22.
//

import SwiftUI

struct NumberFormLinkView: View {
    @ObservedObject var viewModel = NumberFormLinkViewModel()
    lazy var numberFormLink = NumberFormLink(viewModel: viewModel)

    var body: some View {
        NavigationView {
            var mutableSelf = self
            mutableSelf.numberFormLink
            /*
            if #available(iOS 14.0, *) {
                mutableSelf.numberFormLink
                    .toolbar {
                        ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) { Button("Add Low", action: viewModel.addLow) }
                        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) { Button("Add High", action: viewModel.addHigh) }
                    }
            } else {
                VStack {
                    mutableSelf.numberFormLink
                    Toolbar(items: [
                        UIBarButtonItem(
                            title: "Add Low",
                            style: .plain,
                            target: viewModel,
                            action: #selector(viewModel.addLow)
                        ),
                        UIBarButtonItem(
                            barButtonSystemItem: .flexibleSpace,
                            target: nil,
                            action: nil),
                        UIBarButtonItem(
                            title: "Add High",
                            style: .plain,
                            target: viewModel,
                            action: #selector(viewModel.addHigh))
                    ])
                }
            }
             */
        }
        .navigationViewStyle(.stack)
    }
}

struct NumberFormLinkView_Previews: PreviewProvider {
    static var previews: some View {
        NumberFormLinkView()
    }
}

struct DetailView: View {
    let entry: Int
    var body: some View {
        Text("It's a \(entry)!")
    }
}

struct NumberFormLink: View {
    @ObservedObject var viewModel: NumberFormLinkViewModel
//    @Binding var entries: [Int]
//    var currentSelection: Binding<Int?>

    var body: some View {
        ZStack {
            EmptyNavigationLink(
                destination: { DetailView(entry: $0) },
                selection: $viewModel.currentSelection
            )
            Form {
                ForEach(viewModel.entries.sorted(), id: \.self) { entry in
                    NavigationLink(
                        destination: DetailView(entry: entry),
                        label: { Text("The number \(entry)") })
                }
            }
        }
        .navigationBarTitle("NumberFormLink", displayMode: .inline)
        .navigationBarItems(leading: Button("Add Low", action: viewModel.addLow),
                            trailing: Button("Add High", action: viewModel.addHigh))
    }
}

class NumberFormLinkViewModel: ObservableObject {
    @Published var entries = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    @Published var currentSelection: Int? = nil

    @objc func addLow() {
        let newEntry = (entries.min() ?? 1) - 1
        entries.insert(newEntry, at: 1)
        currentSelection = newEntry
    }

    @objc func addHigh() {
        let newEntry = (entries.max() ?? 50) + 1
        entries.append(newEntry)
        currentSelection = newEntry
    }
}
