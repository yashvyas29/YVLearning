//
//  SwiftDataView.swift
//  YVLearning
//
//  Created by Yash Vyas on 08/01/25.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct SwiftDataView: View {
    typealias User = YV_VersionedSchema_02_00_00.User

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var name: String = ""
    var nextKey: Int {
        (users.map { $0.key }.last ?? 0) + 1
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Name", text: $name)
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                Button {
                    let userName = name
                    let user = User(key: nextKey, name: userName)
                    modelContext.insert(user)

                } label: {
                    Label("Add User", systemImage: "plus.square")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background { Color.cyan }
                }
                Spacer(minLength: 24)
                List {
                    ForEach(users) { user in
                        Text(user.name)
                    }
                    .onDelete { indexSet in
                        print("onDelete\n\(indexSet)\nIndexSet:")
                        for index in indexSet {
                            print(index)
                            modelContext.delete(users[index])
                        }
                    }
                    .onMove { indexSet, index in
                        print("onMove\n\(indexSet)\n\(index)\nIndexSet:")
                        for index in indexSet {
                            print(index)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Swift Data")
            .toolbar {
                EditButton()
            }
            .onAppear {
                print(users)
                modelContext.insert(User(key: nextKey, name: "Yash Vyas"))
                /*
                 let predicate = #Predicate<User> { !$0.name.isEmpty }
                 let sortDescriptor = SortDescriptor(\User.name, order: .reverse)
                 let fetchDescriptor = FetchDescriptor<User>(predicate: predicate, sortBy: [sortDescriptor])
                 */
                let users: [User] = (try? modelContext.fetch(.init())) ?? []
                print(users)
            }
        }
    }
}
