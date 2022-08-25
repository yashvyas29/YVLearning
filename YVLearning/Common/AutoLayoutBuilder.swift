//
//  AutoLayoutBuilder.swift
//  YVLearning
//
//  Created by Yash Vyas on 25/08/22.
//

import UIKit

@resultBuilder
struct AutoLayoutBuilder {
    static func buildBlock(_ components: LayoutGroup...) -> [NSLayoutConstraint] {
        return components.flatMap { $0.constraints }
    }

    static func buildOptional(_ component: [LayoutGroup]?) -> [NSLayoutConstraint] {
        return component?.flatMap { $0.constraints } ?? []
    }

    static func buildEither(first component: [LayoutGroup]) -> [NSLayoutConstraint] {
        return component.flatMap { $0.constraints }
    }

    static func buildEither(second component: [LayoutGroup]) -> [NSLayoutConstraint] {
        return component.flatMap { $0.constraints }
    }
}

extension NSLayoutConstraint {
    /// Activate the layouts defined in the result builder parameter `constraints`.
    static func activate(@AutoLayoutBuilder constraints: () -> [NSLayoutConstraint]) {
        activate(constraints())
    }
}

protocol LayoutGroup {
    var constraints: [NSLayoutConstraint] { get }
}
extension NSLayoutConstraint: LayoutGroup {
    var constraints: [NSLayoutConstraint] { [self] }
}
extension Array: LayoutGroup where Element == NSLayoutConstraint {
    var constraints: [NSLayoutConstraint] { self }
}
