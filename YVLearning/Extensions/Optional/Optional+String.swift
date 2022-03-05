//
//  Optional+String.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self == nil || self!.isEmpty
    }

    var hasValue: Bool {
        self != nil && !self!.isEmpty
    }
}
