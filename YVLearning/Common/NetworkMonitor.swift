//
//  NetworkMonitor.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    @Published private(set) var isConnected: Bool = true

    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        isConnected = pathMonitor.currentPath.status == .satisfied
        pathMonitor.pathUpdateHandler = { [unowned self] path in
            self.isConnected = path.status == .satisfied
        }
        pathMonitor.start(queue: queue)
    }

    deinit {
        pathMonitor.cancel()
    }
}
