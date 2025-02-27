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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.accent, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.subheadline)
                        Text("Navigation List")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
final class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var isPresented: Bool = false
    @Published var isFullPresented: Bool = false
}

enum RouteDestination: String, CaseIterable {
    case home, profile, settings, about
}

@available(iOS 16.0, *)
struct NavigationContentView: View {
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack(path: $router.path) {
            ForEach(RouteDestination.allCases, id: \.self) { route in
                Button(route.rawValue.capitalized) {
                    switch route {
                    case .home:
                        router.isPresented = true
                    case .profile:
                        router.isFullPresented = true
                    default:
                        router.path.append(route)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Screens")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: RouteDestination.self) { route in
                switch route {
                case .about:
                    Text("Root").onTapGesture {
                        router.path = .init()
                    }
                default:
                    Text(route.rawValue.capitalized)
                        .onTapGesture {
                            let route = RouteDestination.allCases.randomElement() ?? .home
                            print("Route on tap: \(route)")
                            router.path.append(route)
                        }
                }
            }
            .sheet(isPresented: $router.isPresented) {
                print("Dismissed")
            } content: {
                Text("Presented")
                    .onTapGesture {
                        print("On Tap")
                        router.isPresented = false
                    }
            }
            .fullScreenCover(isPresented: $router.isFullPresented, content: {
                Text("Full Screen Presented")
                    .onTapGesture {
                        router.isFullPresented = false
                    }
            })
        }
    }
}

@available(iOS 16.0, *)
struct NavigationStackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStackView()
    }
}
