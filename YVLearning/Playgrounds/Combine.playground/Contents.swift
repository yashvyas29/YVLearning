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
// Future executes even there is no sink
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

[1, 2, 3, 4, 5, 6]
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

private func romanNumeral(from: Int) throws -> String {
    let romanNumeralDict: [Int: String] =
    [1: "I", 2: "II", 3: "III", 4: "IV", 5: "V"]
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
        receiveCompletion: { print("completion: \($0)") },
        receiveValue: { print("\($0)", terminator: " ") }
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

// Operators
var subscriptions = Set<AnyCancellable>()
let publisher = [5, 6].publisher
publisher
    .prepend(3, 4)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
[1, nil, 2].publisher
    .replaceNil(with: -1)
    .sink(receiveValue: { print($0 ?? 99) })
    .store(in: &subscriptions)
[publisher].publisher
    .switchToLatest()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .merge(with: publisher)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .combineLatest(publisher)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .zip(publisher)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
// Transforms all elements from the upstream publisher with a provided closure.
publisher
    .map { $0*2 }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
// Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.
publisher
    .collect()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
// Applies a closure that collects each element of a stream and publishes a final result upon completion.
publisher
    .reduce(0, +)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .debounce(for: .seconds(0.5), scheduler: ImmediateScheduler.shared)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .throttle(for: .seconds(0.5), scheduler: ImmediateScheduler.shared, latest: true)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
publisher
    .subscribe(on: DispatchQueue.global())
    .receive(on: DispatchQueue.main)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
// Ignores all upstream elements, but passes along the upstream publisher’s completion state (finished or failed).
publisher
    .ignoreOutput()
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
// Transforms elements from the upstream publisher by providing the current element
// to a closure along with the last value returned by the closure.
publisher
    .scan(0) { $0 + $1 }
    .sink(receiveValue: { print($0) })
publisher
    .buffer(size: 2, prefetch: .byRequest, whenFull: .dropOldest)
    .drop { output in
        output == 1
    }

// Backtrace
publisher
    .print()
    .handleEvents(receiveSubscription: { subscription in
        debugPrint(subscription)
    }, receiveOutput: { output in
        debugPrint(output)
    }, receiveCompletion: { completion in
        debugPrint(completion)
    }, receiveCancel: {
        debugPrint("Cancel")
    }, receiveRequest: { demand in
        debugPrint(demand)
    })
    .breakpointOnError()
    .sink(receiveValue: { print($0) })
/*
 Backpressure
 There may be some cases though, where processing those received values takes longer while new values arrive.
 In this case,
 we may need to control the amount of values that arrive to avoid some kind of blocking or overflow.

 This concept of limiting the elements the subscriber receives is called backpressure.
 Operators: debounce, throttle, collect, buffer, drop
 */
class CountSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    var subscription: Subscription?

    // 1.
    func receive(subscription: Subscription) {
        print("subscribed")
        self.subscription = subscription
        subscription.request(.max(1))
    }

    // 2.
    func receive(_ input: Int) -> Subscribers.Demand {
        print("received \(input)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.subscription?.request(.max(2))
        }
        return Subscribers.Demand.none
    }

    // 3.
    func receive(completion: Subscribers.Completion<Never>) {
        debugPrint(completion)
    }
}

// Merge
let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<Int, Never>()
let mergedPublisher = publisher1.merge(with: publisher2)
    .sink { value in
        print("Received value: \(value)")
    }
publisher1.send(1) // Output: Received value: 1
publisher2.send(2) // Output: Received value: 2
publisher1.send(3) // Output: Received value: 3

// CombineLatest
let temperaturePublisher = PassthroughSubject<Int, Never>()
let humidityPublisher = PassthroughSubject<Int, Never>()
let weatherPublisher = Publishers.CombineLatest(temperaturePublisher, humidityPublisher)
    .sink { temperature, humidity in
        print("Temperature: \(temperature), Humidity: \(humidity)")
    }
temperaturePublisher.send(72) // No output yet
humidityPublisher.send(45)     // Output: Temperature: 72, Humidity: 45
temperaturePublisher.send(74) // Output: Temperature: 74, Humidity: 45

// Zip
let usernamePublisher = PassthroughSubject<String, Never>()
let agePublisher = PassthroughSubject<Int, Never>()
let userPublisher = usernamePublisher.zip(agePublisher)
    .sink { username, age in
        print("Username: \(username), Age: \(age)")
    }
usernamePublisher.send("Yash") // No output yet
agePublisher.send(30)          // Output: Username: johndoe, Age: 30
usernamePublisher.send("Vyas") // No output yet
agePublisher.send(28)          // Output: Username: janedoe, Age: 28

let intSubject = PassthroughSubject<Int, Error>()
let stringSubject = PassthroughSubject<String, Error>()
Publishers.Zip(intSubject, stringSubject)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Finished")
        case .failure:
            print("Failure")
        }
    }, receiveValue: { value in
        print(value)
    })
intSubject.send(1)
intSubject.send(2)
stringSubject.send("a")
intSubject.send(3)
stringSubject.send("b")
intSubject.send(completion: .finished)
intSubject.send(4)
stringSubject.send("c")
