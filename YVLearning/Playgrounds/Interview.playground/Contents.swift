import Foundation

func convertIntegerToWord(_ number: Int) {
    let singleDigit = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
    let twoDigits = ["", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen",
                     "Sixteen", "Seventeen", "Eighteen", "nineteen"]
    let tenMultiplier = ["", "", "Twenty", "Thirty", "Fourty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninty"]
    let multiplierNumber = ["Hundred", "Thousand"]

    let string = "\(number)"
    var length = string.count
    if length > 4 {
        print("Not supported.")
    } else if length == 1 {
        print(singleDigit[string.first!.wholeNumberValue!])
    } else {
        var prevChar: Character?
        for char in string {
            if length > 2, char != "0" {
                print(singleDigit[char.wholeNumberValue!])
                print(multiplierNumber[length - 3])
            } else if length == 2 {
                prevChar = char
            } else if length == 1 {
                if prevChar == "1" {
                    print(twoDigits[prevChar!.wholeNumberValue! + char.wholeNumberValue!])
                } else if prevChar!.wholeNumberValue! > 0 {
                    print(tenMultiplier[prevChar!.wholeNumberValue!])
                }
                if char != "0" {
                    print(singleDigit[char.wholeNumberValue!])
                }
            }
            length -= 1
        }
    }
}
convertIntegerToWord(9009)
print()

// Find frequencies of all duplicate elements in an array
func findDuplicateOccurrence(_ array: [Int]) {
    var dict: [Int: Int] = [:]
    for element in array {
        dict[element] = (dict[element] ?? 0) + 1
    }
    for (key, value) in dict {
        print("\(key) occurred \(value) times.")
    }
}
findDuplicateOccurrence([1, 2, 2, 4, 4, 4])
print()

func reverseArray<T>(_ array: [T]) {
    var reversedArray = array
    var start = 0
    var end = array.count - 1
    while start < end {
//        let temp = reversedArray[start]
//        reversedArray[start] = reversedArray[end]
//        reversedArray[end] = temp
        reversedArray.swapAt(start, end)
        start += 1
        end -= 1
    }
    print(reversedArray)
}
reverseArray(Array("AJOOP"))
print()

func reverseArrayRecursively<T>(_ array: [T], start: Int, end: Int) -> [T] {
    if start >= end {
        return array
    }
    var reversedArray = array
    let temp = reversedArray[start]
    reversedArray[start] = reversedArray[end]
    reversedArray[end] = temp
    return reverseArrayRecursively(reversedArray, start: start + 1, end: end - 1)
}
let reversedArray = reverseArrayRecursively([1, 2, 3, 4, 5], start: 0, end: 4)
print(reversedArray)
print()

func sumOfDigits(number: Int) -> Int {
    var num = number
    var sum = 0
    while num != 0 {
        sum += num % 10
        num /= 10
    }
    return sum
}
print(sumOfDigits(number: 01234))
print()

func sumOfDigitsRecursion(number: Int) -> Int {
    return number == 0 ? 0 : number % 10 + sumOfDigitsRecursion(number: number / 10)
}
print(sumOfDigitsRecursion(number: 43210))
print()

func isPalindrome(string: String) -> Bool {
    let array = Array(string)
    var start = 0
    var end = string.count - 1
    while array[start] != array[end] {
        return false
    }
    return true
}
print(isPalindrome(string: "ADDA"))
print()

func sumOfArrayElements(_ array: [Int]) -> Int {
    var sum = 0
    for element in array {
        sum += element
    }
    return sum
}
print(sumOfArrayElements([1, 2, 3, 4]))
print()

func maxAndMinArrayElement(_ array: [Int]) {
    var max = Int.min
    var min = Int.max
    for element in array {
        if element < min {
            min = element
        }
        if max < element {
            max = element
        }
    }
    print("Min element", min)
    print("Max element", max)
}
maxAndMinArrayElement([1, 2, 3, 4])
print()

func secondMaxArrayElement(_ array: [Int]) {
    var max = Int.min
    var secondMax = Int.min
    for element in array where max < element {
        max = element
    }
    for element in array {
        if secondMax < element && element < max {
            secondMax = element
        }
    }
    print("Max element", max)
    if secondMax > Int.min {
        print("Second max element", secondMax)
    } else {
        print("There is no second largest element\n")
    }
}
secondMaxArrayElement([1, 1, 1, 1])
print()

func secondLargestArrayElement(_ array: [Int]) {
    var max = Int.min
    var secondMax = Int.min
    for (index, element) in array.enumerated() {
        if index == 0 {
            max = element
        } else if element > max {
            secondMax = max
            max = element
        } else if element > secondMax && element < max {
            secondMax = element
        }
    }
    print("Max element", max)
    if secondMax > Int.min {
        print("Second max element", secondMax)
    } else {
        print("There is no second largest element\n")
    }
}
secondLargestArrayElement([1, 2, 3, 4])
print()

func secondSmallestArrayElement(_ array: [Int]) {
    var min = Int.max
    var secondMin = Int.max
    for (index, element) in array.enumerated() {
        if index == 0 {
            min = element
        } else if element < min {
            secondMin = min
            min = element
        } else if element < secondMin && element > min {
            secondMin = element
        }
    }
    print("Min element", min)
    if secondMin < Int.max {
        print("Second min element", secondMin)
    } else {
        print("There is no second min element\n")
    }
}
secondSmallestArrayElement([4, 4, 2, 1])
print()

func smallestPositiveMissingNumber(_ array: [Int]) -> Int {
    let sorted = array.sorted()
    var answer = 1
    for element in sorted where element == answer {
        answer += 1
    }
    if answer >= sorted.last ?? 0 {
        print("There is no smallest positive missing number.")
    } else {
        print("Smallest positive missing number:", answer)
    }
    return answer
}
smallestPositiveMissingNumber([1, 3, 4])
print()

func largestPositiveMissingNumber(_ array: [Int]) -> Int {
    let sorted = array.sorted()
    var answer = (array.last ?? 0) - 1
    for element in sorted.reversed() where element == answer {
        answer -= 1
    }
    if answer <= 0 {
        print("There is no largest missing number.")
    } else {
        print("Largest positive missing number:", answer)
    }
    return answer
}
largestPositiveMissingNumber([1, 2, 3, 4])
print()

func stringContainsSubstring(string: String, subString: String) -> Bool {
//    let range = string.ranges(of: subString)
//    print(range)
    return string.contains(subString)
}
print(stringContainsSubstring(string: "Yash Vyas", subString: "Yash"))
print()

func insertionSort(_ array: [Int]) -> [Int] {
    var sortedArray = array             // 1
    for index in 1..<sortedArray.count {         // 2
        var currentIndex = index
        while currentIndex > 0 && sortedArray[currentIndex] < sortedArray[currentIndex - 1] { // 3
            sortedArray.swapAt(currentIndex - 1, currentIndex)
            currentIndex -= 1
        }
    }
    return sortedArray
}
print(insertionSort([ 10, -1, 3, 9, 2, 27, 8, 5, 1, 3, 0, 26 ]))
print()

/*
func selectionSort(_ array: [Int]) -> [Int] {
    guard array.count > 1 else { return array }  // 1

    var a = array                    // 2

    for x in 0 ..< a.count - 1 {     // 3

        var lowest = x
        for y in x + 1 ..< a.count {   // 4
            if a[y] < a[lowest] {
                lowest = y
            }
        }

        if x != lowest {               // 5
            a.swapAt(x, lowest)
        }
    }
    return a
}
print(selectionSort([ 10, -1, 3, 9, 2, 27, 8, 5, 1, 3, 0, 26 ]))
print()

func bubbleSort(_ a: [Int]) -> [Int] {
    guard a.count > 1 else { return a }  // 1
    var array = a
    for i in 0..<array.count {
        for j in 1..<array.count - i {
            if array[j] < array[j-1] {
                let tmp = array[j-1]
                array[j-1] = array[j]
                array[j] = tmp
            }
        }
    }
    return array
}
print(bubbleSort([ 10, -1, 3, 9, 2, 27, 8, 5, 1, 3, 0, 26 ]))
print()

func mergeSort(_ array: [Int]) -> [Int] {
    guard array.count > 1 else { return array }    // 1

    func merge(leftPile: [Int], rightPile: [Int]) -> [Int] {
        // 1
        var leftIndex = 0
        var rightIndex = 0

        // 2
        var orderedPile = [Int]()
        orderedPile.reserveCapacity(leftPile.count + rightPile.count)

        // 3
        while leftIndex < leftPile.count && rightIndex < rightPile.count {
            if leftPile[leftIndex] < rightPile[rightIndex] {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
            } else if leftPile[leftIndex] > rightPile[rightIndex] {
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            } else {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            }
        }

        // 4
        while leftIndex < leftPile.count {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
        }

        while rightIndex < rightPile.count {
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        }

        return orderedPile
    }

    let middleIndex = array.count / 2              // 2

    let leftArray = mergeSort(Array(array[0..<middleIndex]))             // 3

    let rightArray = mergeSort(Array(array[middleIndex..<array.count]))  // 4

    return merge(leftPile: leftArray, rightPile: rightArray)             // 5
}
print(mergeSort([ 10, -1, 3, 9, 2, 27, 8, 5, 1, 3, 0, 26 ]))
print()

func mergeSortBottomUp<T>(_ a: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
    let n = a.count

    var z = [a, a]      // 1
    var d = 0

    var width = 1
    while width < n {   // 2

        var i = 0
        while i < n {     // 3

            var j = i
            var l = i
            var r = i + width

            let lmax = min(l + width, n)
            let rmax = min(r + width, n)

            while l < lmax && r < rmax {                // 4
                if isOrderedBefore(z[d][l], z[d][r]) {
                    z[1 - d][j] = z[d][l]
                    l += 1
                } else {
                    z[1 - d][j] = z[d][r]
                    r += 1
                }
                j += 1
            }
            while l < lmax {
                z[1 - d][j] = z[d][l]
                j += 1
                l += 1
            }
            while r < rmax {
                z[1 - d][j] = z[d][r]
                j += 1
                r += 1
            }

            i += width*2
        }

        width *= 2
        d = 1 - d      // 5
    }
    return z[d]
}
print(mergeSortBottomUp([ 10, -1, 3, 9, 2, 27, 8, 5, 1, 3, 0, 26 ], <))
print()

// String search
extension String {
    func indexOf(_ pattern: String) -> Int? {
        for i in self.indices {
            var j = i
            var found = true
            for p in pattern.indices {
                if j == self.endIndex || self[j] != pattern[p] {
                    found = false
                    break
                } else {
                    j = self.index(after: j)
                }
            }
            if found {
                return i.utf16Offset(in: self)
//                return distance(from: startIndex, to: i)
            }
        }
        return nil
    }

    func indexUsingBoyerMoore(of pattern: String) -> Index? {
        // Cache the length of the search pattern because we're going to
        // use it a few times and it's expensive to calculate.
        let patternLength = pattern.count
        guard patternLength > 0, patternLength <= count else { return nil }

        // Make the skip table. This table determines how far we skip ahead
        // when a character from the pattern is found.
        var skipTable = [Character: Int]()
        for (i, c) in pattern.enumerated() {
            skipTable[c] = patternLength - i - 1
        }

        // This points at the last character in the pattern.
        let p = pattern.index(before: pattern.endIndex)
        let lastChar = pattern[p]

        // The pattern is scanned right-to-left, so skip ahead in the string by
        // the length of the pattern. (Minus 1 because startIndex already points
        // at the first character in the source string.)
        var i = index(startIndex, offsetBy: patternLength - 1)

        // This is a helper function that steps backwards through both strings
        // until we find a character that doesn’t match, or until we’ve reached
        // the beginning of the pattern.
        func backwards() -> Index? {
            var q = p
            var j = i
            while q > pattern.startIndex {
                j = index(before: j)
                q = index(before: q)
                if self[j] != pattern[q] { return nil }
            }
            return j
        }

        // The main loop. Keep going until the end of the string is reached.
        while i < endIndex {
            let c = self[i]

            // Does the current character match the last character from the pattern?
            if c == lastChar {

                // There is a possible match. Do a brute-force search backwards.
                if let k = backwards() { return k }

                // If no match, we can only safely skip one character ahead.
                i = index(after: i)
            } else {
                // The characters are not equal, so skip ahead. The amount to skip is
                // determined by the skip table. If the character is not present in the
                // pattern, we can skip ahead by the full pattern length. However, if
                // the character *is* present in the pattern, there may be a match up
                // ahead and we can't skip as far.
                i = index(i, offsetBy: skipTable[c] ?? patternLength, limitedBy: endIndex) ?? endIndex
            }
        }
        return nil
    }
}

print("Yash Vyas".indexOf("Vyas") ?? -1)
print()

/*
 *
 **
 ***
 ****
 */
func triangleOfAstrisks(_ rows: Int) {
    for i in 1...rows {
        for _ in 1...i {
            print("*", terminator: "")
        }
        print()
    }
}

triangleOfAstrisks(4)
print()

/*
 *******
  *****
   ***
    *
 */
func reverseTriangleOfAstrisks(_ rows: Int) {
    for i in (1...rows).reversed() {
        for _ in 0...rows-i {
            print(" ", terminator: "")
        }
        for _ in 0...2*(i-1) {
            print("*", terminator: "")
        }
        print()
    }
}

reverseTriangleOfAstrisks(4)
print()
 */

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
