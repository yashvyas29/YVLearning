//
//  Optional+Nil.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

extension Optional {
    var isNil: Bool {
        self == nil
    }

    var isNotNil: Bool {
        self != nil
    }
}
