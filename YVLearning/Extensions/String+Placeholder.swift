//
//  String+Redacted.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation

extension String {
    static func placeholder(length: Int) -> String {
        String(Array(repeating: "X", count: length))
    }
}
