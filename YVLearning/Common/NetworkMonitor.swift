//
//  NetworkMonitor.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let pathMonitor = NWPathMonitor()
    private(set) var isConnected: Bool = false

    private init() {
        pathMonitor.pathUpdateHandler = { [unowned self] path in
            self.isConnected = path.status == .satisfied
        }
        pathMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }

    deinit {
        pathMonitor.cancel()
    }
}
