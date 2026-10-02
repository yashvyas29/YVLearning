//
//  View+Navigation.swift
//  YVLearning
//
//  Created by Yash Vyas on 23/10/22.
//

import SwiftUI

extension View {
	func navigate<Destination: View>(to destination: Destination, when isActive: Binding<Bool>) -> some View {
		self
			.navigationDestination(isPresented: isActive) {
				destination
			}
	}

	func navigate(to route: Binding<Route?>) -> some View {
		self
			.navigationDestination(item: route) { route in
				route.destination
			}
	}
}

enum FirstRoute: Identifiable {
    case one
    case two

    var id: Self {
        return self
    }
}

enum Route: Identifiable, Hashable {
    case first(FirstRoute)
    case second

    var id: Self {
        return self
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .first(let route):
            switch route {
            case .one:
                Text("First One")
            case .two:
                Text("First Two")
            }
        case .second:
            Text("Second")
        }
    }
}
