//: [Previous](@previous)

import Foundation

// Codility
var arr = [1, 2, 3]
if let element = arr.first(where: { $0 == 1 }),
   let index = arr.firstIndex(of: element) {
    arr.remove(at: index)
}

arr.removeAll { $0 == 1 }

struct Subscription {
    let identifier: String
}
extension Subscription: Equatable {}

arr.removeFirst(2)

arr.filter { $0 == 1 }.first

var dict: [String: () -> Void] = [:]
dict.removeValue(forKey: "")

/*
 class A {}
 extension A {
 // @objc
 func abc() {}
 }

 class A1: P1 {
 // override
 func abc() {
 print("A1 -> abc")
 }
 }

 let a1 = A1()
 a1.abc()

 protocol P1 {
 func abc()
 }

 extension P1 { // Extension
 func abc() {
 print("P1 -> abc")
 }
 }

 protocol P2: P1 {} // Inheritence
 protocol P3: P1, P2 {}  // Composition
 typealias P23 = P2 & P3 // Composition
 protocol P4: P23 {} // Composition

 "Yash Vyas".uppercased()
 "Yash Vyas".uppercased
 String.uppercased
 */

// map vs flatMap
/*
 let numbers = [1, 2, 3, 4]
 let mapped = numbers.map { Array(repeating: $0, count: $0) }
 // [[1], [2, 2], [3, 3, 3], [4, 4, 4, 4]]
 let flatMapped = numbers.flatMap { Array(repeating: $0, count: $0) }
 // [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
 */
/*
 flatMap returns an array containing the concatenated results of calling the given transformation
 with each element of this sequence.
 Use this method to receive a single-level collection when your transformation produces
 a sequence or collection for each element.
 */

// map vs compactMap
/*
 let possibleNumbers = ["1", "2", "three", "///4///", "5"]
 let mappedPN: [Int?] = possibleNumbers.map { str in Int(str) }
 // [1, 2, nil, nil, 5]

 let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
 // [1, 2, 5]
 */
/*
 compactMap returns an array containing the non-nil results of calling the given transformation
 with each element of this sequence.
 */

// What will be printed ?
// 1)
/*
 print("\nExample1\n")
 final class MyClass {
 func foo() {
 DispatchQueue.main.async {
 print("a")
 DispatchQueue.main.async {
 print("b")
 }
 print("c")
 DispatchQueue.main.async {
 print("d")
 }
 print("e")
 }
 }
 }

 let instance = MyClass()
 instance.foo()
 print("f")
 */

// 2)
/*
 print("\nExample2\n")
 final class MyClass {
 func foo() {
 DispatchQueue.main.async {
 print("a")
 DispatchQueue.main.sync { // Deadlock
 print("b")
 }
 print("c")
 DispatchQueue.main.async {
 print("d")
 }
 print("e")
 }
 }
 }

 let instance = MyClass()
 instance.foo()
 print("f")
 */

// 3)
// print("\nExample3\n")
/*
 ARC will keep something in memory, as long as an allocated memory is strongly referenced by some variable.
 If it(ARC) found some allocated memory doesn't have any strong reference it will dealloc it.
 */
/*
 final class A {}
 final class B {}

 weak var a = A()
 weak var b = B()

 print(a)
 print(b)
 */

// 4)
/*
 print("\nExample4\n")
 final class Box: CustomDebugStringConvertible {
 var device: String

 init(device: String) {
 self.device = device
 }

 var debugDescription: String {
 return "device: \(device)"
 }
 }

 var box = Box(device: "iPhone X")
 var boxes = [box]
 print(boxes)

 box.device = "iPhone 5S"
 print(boxes)
 */

// 5)
/*
 print("\nExample5\n")
 var a = 24
 let closure = { [a] in
 print(a)
 }
 closure()
 a = 30
 closure()
 */

// 6)
/*
 print("\nExample6\n")
 final class MyClass {
 func foo() {
 let queue = DispatchQueue(label: "test")
 queue.async {
 print("a")
 queue.async {
 print("b")
 }
 print("c")
 queue.async {
 print("d")
 }
 print("e")
 }
 }
 }

 let instance = MyClass()
 instance.foo()
 print("f")
 */

// 7)
/*
 print("\nExample7\n")
 final class MyClass {
 func foo() {
 let queueTest1 = DispatchQueue(label: "test")
 let queueTest2 = DispatchQueue(label: "test")
 queueTest1.async {
 print("a")
 }
 queueTest2.async {
 print("b")
 }
 }
 }

 let instance = MyClass()
 instance.foo()
 */

// 8)
/*
 print("\nExample8\n")
 DispatchQueue.main.asyncAfter(deadline: .now()) {
 print("A")
 }
 DispatchQueue.main.async {
 print("B")
 }
 DispatchQueue.global().async {
 print("C")
 }
 print("D")
 */

// Swift program to use filter() function
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
// Transforming elements from an array
let evenSquares = numbers.filter { $0 % 2 == 0 }.map { $0 * $0 }
print(evenSquares)

// Swift program to use reduce() function
let words = ["geeks", "for", "geeks"]
// Concatenating the array of string
let sentence = words.reduce("", { $0 + " " + $1 })
print(sentence)
