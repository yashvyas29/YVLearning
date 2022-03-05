//
//  Optional+Bool.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import Foundation

extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        if let localSelf = self {
            return localSelf
        } else {
            return false
        }
    }

    var isNilOrFalse: Bool {
        if let localSelf = self {
            return !localSelf
        } else {
            return true
        }
    }
}
