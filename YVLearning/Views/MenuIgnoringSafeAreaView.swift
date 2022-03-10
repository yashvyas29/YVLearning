//
//  IgnoringSafeAreaView.swift
//  YVLearning
//
//  Created by Yash Vyas on 10/03/22.
//

import SwiftUI

@available(iOS 14.0, *)
struct MenuIgnoringSafeAreaView: View {
    private let menuOptions = ["1", "2", "3"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Menu("Actions") {
                    ForEach(menuOptions, id: \.self, content: { Text($0) })
                    //                List(menuOptions, id: \.self, rowContent: { Text($0) })
                    Button("Duplicate", action: {})
                    Button("Rename", action: {})
                    Button("Delete", action: {})
                    Menu("Copy") {
                        Button("Copy", action: {})
                        Button("Copy Formatted", action: {})
                        Button("Copy Library Path", action: {})
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Section(header: Text("Primary actions")) {
                                Button(action: {}) {
                                    Label("Create a file", systemImage: "doc")
                                }

                                Button(action: {}) {
                                    Label("Create a folder", systemImage: "folder.badge.plus")
                                }
                            }

                            Section(header: Text("Secondary actions")) {
                                Button(action: {}) {
                                    Label("Remove old files", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            }

                            Section(header: Text("Turnery actions")) {
                                Button(action: {}) {
                                    Label("Add old files", systemImage: "folder.badge.plus")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    label: {
                        Label("Add", systemImage: "plus")
                    }
                    .foregroundColor(.yellow)
                    }
                }
            }
        }
        .foregroundColor(.yellow)
    }
}

@available(iOS 14.0, *)
struct IgnoringSafeAreaView_Previews: PreviewProvider {
    static var previews: some View {
        MenuIgnoringSafeAreaView()
    }
}
