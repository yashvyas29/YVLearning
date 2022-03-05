//
//  OSLog+Categories.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation
import os.log

extension OSLog {
    // App bundle identifier
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the app life cycles
    static let appCycle = OSLog(subsystem: subsystem, category: "appcycle")

    /// Logs the view life cycles
    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")
}
