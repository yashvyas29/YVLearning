//
//  NameListView.swift
//  YVLearning
//
//  Created by Yash Vyas on 14-02-2025.
//

import SwiftUI
import Combine

struct NameListView: View {

    @State private var names = ["Jayant", "Yash", "Amit", "Rohit", "Shubham"]
    @State private var searchedNames: [String] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List(searchedNames.isEmpty ? names : searchedNames, id: \.self) { name in
                HStack {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Text(name)
                }
                .apply {
                    if #available(iOS 15.0, *) {
                        $0.listRowSeparatorTint(.red)
                    } else {
                        $0
                    }
                }
                .apply {
                    if #available(iOS 16.0, *) {
                        $0.alignmentGuide(.listRowSeparatorLeading) { _ in
                            return -20
                        }
                    } else {
                        $0.padding(.leading, 16)
                    }
                }
            }
            .apply {
                if #unavailable(iOS 16.0) {
                    $0.padding(.leading, -16)
                } else {
                    $0
                }
            }
            .apply {
                if #available(iOS 14.0, *) {
                    $0.onChange(of: searchText) { _ in
                        searchedNames = names.filter {
                            $0.lowercased().contains(searchText.lowercased())
                        }
                    }
                } else {
                    $0.onReceive(Just(searchText)) { _ in
                        searchedNames = names.filter {
                            $0.lowercased().contains(searchText.lowercased())
                        }
                    }
                }
            }
            .navigationBarTitle("Users")
            .apply {
                if #available(iOS 15.0, *) {
                    $0.searchable(text: $searchText, prompt: "Search Name")
                    $0.refreshable {
                        print("Refreshing List")
                    }
                }
            }
        }
    }
}

#Preview {
    NameListView()
}
