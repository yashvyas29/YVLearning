//: The Open/Closed Principle

//: [Previous](@previous)

import UIKit

class Shape {
    //...
}

extension Shape: CustomStringConvertible {
    public var description: String {
        return "Shape base class"
    }
}

let shape = Shape()
print(shape)

extension UITableView {
    public func deselectSelectedRow(animated: Bool) {
        if let indexPathForSelectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
}

//: [Next](@next)
