// To use app classes in playground
import YVLearning
// To use Task in playground
import _Concurrency
// To hide the unnecessary duplicate framework logs
//import PlaygroundSupport
//defer{ PlaygroundPage.current.finishExecution() }

let structuredConcurrency = StructuredConcurrency()
/*
Task {
    let imagesSerial = try? await structuredConcurrency.fetchImages()
    debugPrint("fetchImages: \(imagesSerial?.count ?? 0)")
    // Playground doesn't support async let till
//    async let imagesParallel = try? structuredConcurrency.fetchImages()
//    debugPrint("fetchImages async let: \(await imagesParallel?.count ?? 0)")
}
 */

func asyncIntSquareStream(forValues values: [Int]) -> AsyncStream<Int> {
    var index = 0
    return AsyncStream {
        guard index < values.count else {
            return nil
        }

        let value = values[index]
        index += 1

        let asyncSquareValueTask = Task {
            value * value
        }
        return await asyncSquareValueTask.value
    }
}

Task {
    let values = [0, 1, 2, 3, 4, 5]
    var index = 0
    for await squareValue in asyncIntSquareStream(forValues: values) {
        debugPrint("Square of \(values[index]) is \(squareValue)")
        index += 1
    }

    var valueIterator = values.makeIterator()
    let hasNonZeroValues = await asyncIntSquareStream(forValues: values).allSatisfy { $0 > 0 }
    debugPrint("Are all values greater than zero? : \(hasNonZeroValues)")
    if let minValue = await asyncIntSquareStream(forValues: values).min() {
        debugPrint("Minimum value: \(minValue)")
    }
    if let maxValue = await asyncIntSquareStream(forValues: values).max() {
        debugPrint("Maximum value: \(maxValue)")
    }
    let sum = await asyncIntSquareStream(forValues: values).reduce(0, +)
    debugPrint("Sum of all the values: \(sum)")
    var asyncIntSquareIterator = asyncIntSquareStream(forValues: values).makeAsyncIterator()
    while let value = valueIterator.next(),
          let squareValue = await asyncIntSquareIterator.next() {
        debugPrint("Square of \(value) is \(squareValue)")
    }
}
