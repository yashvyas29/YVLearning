//: [Previous](@previous)

import Foundation

final public class AppSettings {

    public static let shared = AppSettings()

    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)

    private var settings: [String: Any] = ["Theme": "Dark",
                                           "MaxConsurrentDownloads": 4]

    private init() {}

    public func string(forKey key: String) -> String? {
        var result: String?
        concurrentQueue.sync {
            result = settings[key] as? String
        }
        return result
    }

    public func int(forKey key: String) -> Int? {
        var result: Int?
        concurrentQueue.sync {
            result = settings[key] as? Int
        }
        return result
    }

    public func set(value: Any, forKey key: String) {
        concurrentQueue.async( flags: .barrier ) {
            self.settings[key] = value
        }
    }
}

let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
let callCount = 100

for callIndex in 1...callCount {
    concurrentQueue.async {
        AppSettings.shared.set(value: callIndex, forKey: String(callIndex))
    }
}

while AppSettings.shared.int(forKey: String(callCount)) != callCount {
    // nop = no operation
}

//: [Next](@next)
