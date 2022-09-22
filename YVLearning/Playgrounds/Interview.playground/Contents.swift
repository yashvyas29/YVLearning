import Foundation

func convertIntegerToWord(_ number: Int) {
    let singleDigit = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
    let twoDigits = ["", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "nineteen"]
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
        let temp = reversedArray[start]
        reversedArray[start] = reversedArray[end]
        reversedArray[end] = temp
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
    while(num != 0) {
        sum = sum + num % 10
        num = num / 10
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
    for element in array {
        if max < element {
            max = element
        }
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
    for element in sorted {
        if element == answer {
            answer += 1
        }
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
    for element in sorted.reversed() {
        if element == answer {
            answer -= 1
        }
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
