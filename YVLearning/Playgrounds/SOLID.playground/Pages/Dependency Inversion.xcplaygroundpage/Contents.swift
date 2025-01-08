//: The Dependency Inversion Principle

//: [Previous](@previous)

import Foundation

// MARK: - Dependency Created Internally

class Persistence {
    private var logger = Logger()
    
    func save(data: Data, to url: URL) throws {
        do {
            try data.write(to: url)
        }
        catch {
            logger.log("\(error)", severity: 10)
        }
    }
}

class Logger {
    func log(_ message: String, severity: Int) {
        print("\(message), severity: \(severity)")
    }
}

// MARK: - Introducing the Logging Protocol

class Persistence {
    private let logger: Logging

    init(logger: Logging) {
        self.logger = logger
    }

    func save(data: Data, to url: URL) throws {
        do {
            try data.write(to: url)
        }
        catch {
            logger.log("\(error)", severity: 10)
        }
    }
}

protocol Logging {
    func log(_ message: String, severity: Int)
}

class Logger: Logging {
    func log(_ message: String, severity: Int) {
        print("\(message), severity: \(severity)")
    }
}
