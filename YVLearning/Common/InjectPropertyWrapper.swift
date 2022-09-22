//
//  InjectPropertyWrapper.swift
//  YVLearning
//
//  Created by Yash Vyas on 15/09/22.
//

import Foundation

@propertyWrapper
struct Inject<Component> {
    let wrappedValue: Component

    init() {
        self.wrappedValue = Resolver.shared.resolve(Component.self)
    }
}

class Resolver {
    static let shared = Resolver()
//    private var container = Container()

    func resolve<T>(_ type: T.Type) -> T {
//        container.resolve(type)!
        fatalError("not yet implemented")
    }

    /*
    func setContainer(_ container: Container) {
        self.container = container
    }

    func setResolver(_ resolver: Swinject.Resolver) {
        if let container = resolver as? Container {
            self.container = container
        }
    }

    @discardableResult
    func autoregister<Service, A>(_ service: Service.Type, name: String? = nil, initializer: @escaping (A) -> Service) -> ServiceEntry<Service> {
        container.autoregister(service, initializer: initializer)
    }
     */
}
