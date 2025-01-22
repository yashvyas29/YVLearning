//
//  NavigationStackView.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/01/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct NavigationStackView: View {
    var users: [User] = []
    @State var path = NavigationPath()

    struct User: Identifiable, Hashable {
        let id: Int
        let name: String
    }

    init() {
        users.append(.init(id: 1, name: "11"))
        users.append(.init(id: 1, name: "12"))
        users.append(.init(id: 2, name: "13"))
        users.append(.init(id: 3, name: "14"))
        users.append(.init(id: 3, name: "15"))
    }

    var body: some View {
        NavigationStack(path: $path) {
            List(users) { user in
                HStack {
                    NavigationLink(user.id.description, value: user.id)
                    Button(user.name) {
                        path.append(user.name)
                    }
                }
                .padding()
                .listRowSeparator(background: .red)
                .buttonStyle(.plain)
            }
            .navigationDestination(for: Int.self) { userId in
                VStack {
                    Text(userId.description)
                    Button("Back to Root") {
                        path = .init()
                    }
                }
                    .onTapGesture {
                        path.append(userId)
                    }
            }
            .navigationDestination(for: String.self) { userName in
                Text(userName)
            }
        }
    }
}

@available(iOS 16.0, *)
struct NavigationStackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStackView()
    }
}
