//
//  Optional+Collection.swift
//  YVLearning
//
//  Created by Yash Vyas on 17-03-2025.
//

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self == nil || self!.isEmpty
    }

    var hasValue: Bool {
        self != nil && !self!.isEmpty
    }
}
