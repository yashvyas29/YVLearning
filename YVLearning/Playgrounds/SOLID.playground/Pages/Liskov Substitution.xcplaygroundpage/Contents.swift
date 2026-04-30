//: The Liskov Substitution Principle

//: [Previous](@previous)

import Foundation

class Shape {
    func area() -> Double {
        return 0
    }
}

var shapes = [Shape]()

class Rectangle: Shape {
    private var length, width: Double

    override func area() -> Double {
        return length * width
    }

    init(length: Double, width: Double) {
        self.length = length
        self.width = width
    }
}

class Square: Shape {
    private var side: Double

    override func area() -> Double {
        return side * side
    }

    init(side: Double) {
        self.side = side
    }
}

class Circle: Shape {
    private var radius: Double

    override func area() -> Double {
        return Double.pi * radius * radius
    }

    init(radius: Double) {
        self.radius = radius
    }
}

let square = Square(side: 1)
let rectangle = Rectangle(length: 2, width: 3)
let circle = Circle(radius: 2)

shapes.append(square)
shapes.append(rectangle)
shapes.append(circle)
// 1 + 6 + 12.56
let totalArea = shapes.reduce(0, { $0 + $1.area() })
print(totalArea)
// Output: 19.5663706143592

//: [Next](@next)
