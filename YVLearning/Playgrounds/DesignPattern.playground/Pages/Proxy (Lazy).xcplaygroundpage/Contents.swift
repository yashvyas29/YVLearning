//: [Previous](@previous)

import Foundation

class RandomIntWithID {
    var value: Int = {
        print("value initialized")
        return Int.random(in: Int.min...Int.max)
    }()

    lazy var uid: String = {
        print("uid initialized")
        return UUID().uuidString
    }()
}

let randomIntWithID = RandomIntWithID()
print(randomIntWithID.uid)

//: [Next](@next)
