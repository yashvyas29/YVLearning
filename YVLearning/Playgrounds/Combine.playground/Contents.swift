import Combine
import Foundation
// import PlaygroundSupport

let passThroughSubject = PassthroughSubject<Int, Never>()
let currentValueSubject = CurrentValueSubject<Int, Never>(0)
var cancellables: Set<AnyCancellable> = []

passThroughSubject.send(11)
currentValueSubject.send(11)

passThroughSubject.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Pass through subject finished.")
    }
} receiveValue: { value in
    debugPrint("Pass through subject receiveValue \(value).")
}
.store(in: &cancellables)

currentValueSubject.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Current value subject finished.")
    }
} receiveValue: { value in
    debugPrint("Current value subject receiveValue \(value).")
}
.store(in: &cancellables)

passThroughSubject.send(1)
passThroughSubject.send(2)
passThroughSubject.send(3)
passThroughSubject.send(completion: .finished)
passThroughSubject.send(4)

currentValueSubject.send(1)
currentValueSubject.send(2)
currentValueSubject.send(3)
currentValueSubject.send(completion: .finished)
currentValueSubject.send(4)

enum MyError: Error { case error }

let just = Just(1).eraseToAnyPublisher()
// Future even executes even there is no sink
let future = Future<Int, MyError> { promise in
    debugPrint("Future")
    promise(.success(1))
    // promise(.failure(.error))
}.eraseToAnyPublisher()
// Deferred future only gets called after sink
let deferredFuture = Deferred {
    Future<Int, MyError> { promise in
        debugPrint("Deferred Future")
        promise(.success(1))
        // promise(.failure(.error))
    }
}.eraseToAnyPublisher()
// Allows for recording a series of inputs and a completion, for later playback to each subscriber.
let record = Record<Int, MyError>(output: [1, 2, 3], completion: .failure(.error)).eraseToAnyPublisher()
/*
let record = Record<Int, MyError> { recording in
    debugPrint("Record")
    recording.receive(1)
    recording.receive(2)
    recording.receive(3)
    recording.receive(completion: .finished)
}
 */
let empty = Empty<Int, MyError>() // Never produce value, finishes imediately
// let empty = Empty<Int, MyError>(completeImmediately: false) // Never produce value, never finishes
let fail = Fail<Int, MyError>(error: .error) // Immediately terminates with the specified error.

just.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Just finished.")
    }
} receiveValue: { value in
    debugPrint("Just receiveValue \(value).")
}
.store(in: &cancellables)

future.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Future finished.")
    case .failure(let error):
        debugPrint("Future failure \(error).")
    }
} receiveValue: { value in
    debugPrint("Future receiveValue \(value).")
}
.store(in: &cancellables)

deferredFuture.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Deferred Future finished.")
    case .failure(let error):
        debugPrint("Deferred Future failure \(error).")
    }
} receiveValue: { value in
    debugPrint("Deferred Future receiveValue \(value).")
}
.store(in: &cancellables)

record.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Record finished.")
    case .failure(let error):
        debugPrint("Record failure \(error).")
    }
} receiveValue: { value in
    debugPrint("Record receiveValue \(value).")
}
.store(in: &cancellables)

empty.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Empty finished.")
    case .failure(let error):
        debugPrint("Empty failure \(error).")
    }
} receiveValue: { value in
    debugPrint("Empty receiveValue \(value).")
}
.store(in: &cancellables)

fail.sink { completion in
    switch completion {
    case .finished:
        debugPrint("Fail finished.")
    case .failure(let error):
        debugPrint("Fail failure \(error).")
    }
} receiveValue: { value in
    debugPrint("Fail receiveValue \(value).")
}
.store(in: &cancellables)

// PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true
/*
Timer.publish(every: 1, on: .main, in: .default)
    .autoconnect()
    .flatMap({ (input) in
        Just(input)
            .tryMap({ (input) -> String in
                if Bool.random() {
                    throw MyError.error
                } else {
                    return "we're in the else case"
                }
            })
            .catch { (error) in
                Just("replaced error")
            }
    })
    .sink(receiveCompletion: { (completion) in
        print(completion)
        // PlaygroundSupport.PlaygroundPage.current.finishExecution()
    }) { (output) in
        debugPrint(output)
    }
    .store(in: &cancellables)
 */

[1,2,3,4,5,6]
    .publisher
    .flatMap { value in
        Just(value)
            .tryMap { value throws -> Int in
                if value == 2 { throw MyError.error }
                return value
            }
            .replaceError(with: 666)
    }
    .sink(receiveCompletion: { (completion) in
        print(completion)
    }, receiveValue: { (value) in
        print(value)
    })
    .store(in: &cancellables)

private func romanNumeral(from:Int) throws -> String {
    let romanNumeralDict: [Int : String] =
    [1:"I", 2:"II", 3:"III", 4:"IV", 5:"V"]
    guard let numeral = romanNumeralDict[from] else {
        throw MyError.error
    }
    return numeral
}

[5, 4, 3, 2, 1, 10]
    .publisher
    .tryMap { try romanNumeral(from: $0) }
    .replaceError(with: "X")
    .sink(
        receiveCompletion: { print ("completion: \($0)") },
        receiveValue: { print ("\($0)", terminator: " ") }
    )
    .store(in: &cancellables)

class StringSubscriber: Subscriber {
    typealias Input = String
    typealias Failure = Never

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: String) -> Subscribers.Demand {
        print("Received: \(input), Transformed into: \(input.uppercased())")
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion event:", completion)
    }
}

let stringPublisher = [
    "Warsaw", "Barcelona", "New York", "Toronto"
].publisher

let stringSubscriber = StringSubscriber()

stringPublisher.subscribe(stringSubscriber)

// Generic approach
class GenericSubscriber<T>: Subscriber {
    typealias Input = T
    typealias Failure = Never

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: T) -> Subscribers.Demand {
        print("Received: \(input)", T.self)
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion event:", completion)
    }
}

let publisherOfInts = [
    1, 2, 3, 4
].publisher

let publisherOfStrings = [
    "1", "2", "3", "4"
].publisher

let subscriberOfInt = GenericSubscriber<Int>()
let subscriberOfString = GenericSubscriber<String>()

publisherOfInts.subscribe(subscriberOfInt)
publisherOfStrings.subscribe(subscriberOfString)

let subscriber = AnySubscriber<Int, Never> { subscription in
    subscription.request(.unlimited)
} receiveValue: { value in
    debugPrint("AnySubscriber receiveValue \(value)")
    return .none
} receiveCompletion: { completion in
    debugPrint("AnySubscriber completion \(completion)")
}
Just(5).subscribe(subscriber)
