//: [Previous](@previous)

import Foundation

/*
extension UserDefaults {
    func set(date: Date?, forKey key: String) {
        self.set(date, forKey: key)
    }

    func date(forKey key: String) -> Date? {
        return self.value(forKey: key) as? Date
    }
}

let userDefaults = UserDefaults.standard
userDefaults.set(date: Date(), forKey: "now")
print(userDefaults.date(forKey: "now") ?? "?")
 */

class UserDefaultsDecorator: UserDefaults {
    private var userDefaults = UserDefaults.standard

    convenience init(userDefaults: UserDefaults) {
        self.init()
        self.userDefaults = userDefaults
    }

    func set(date: Date?, forKey key: String) {
        userDefaults.set(date, forKey: key)
    }

    func date(forKey key: String) -> Date? {
        return userDefaults.value(forKey: key) as? Date
    }
}

let userDefaultsDecorator = UserDefaultsDecorator()

userDefaultsDecorator.set(42, forKey: "the answer")
print(userDefaultsDecorator.string(forKey: "the answer") ?? "?")

userDefaultsDecorator.set(date: Date(), forKey: "now")
print(userDefaultsDecorator.date(forKey: "now") ?? "?")

//: [Next](@next)
