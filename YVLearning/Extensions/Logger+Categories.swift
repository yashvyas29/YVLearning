//
//  Logger+Categories.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
extension Logger {
    // App bundle identifier
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the app life cycles
    static let appCycle = Logger(subsystem: subsystem, category: "appcycle")

    /// Logs the view life cycles
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
}
