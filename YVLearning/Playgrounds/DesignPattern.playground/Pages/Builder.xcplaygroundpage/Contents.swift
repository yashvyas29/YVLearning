
//:[Previous](@previous)

import UIKit

struct User {
    let id: String
    let firstName: String
    let middleName: String?
    let lastName: String

    var fullName: String {
        "\(firstName)\((middleName != nil || !middleName!.isEmpty) ? " \(middleName!) " : " ")\(lastName)"
    }

    private init?(builder: Builder) {
        guard let id = builder.id,
              let firstName = builder.firstName,
              let lastName = builder.lastName else {
            return nil
        }
        self.id = id
        self.firstName = firstName
        self.middleName = builder.middleName
        self.lastName = lastName
    }

    private init(id: String, firstName: String, middleName: String? = nil, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
    }

    static func make(builderBlock: (Builder) -> Void) -> Self? {
        let builder = Builder()
        builderBlock(builder)
        return builder.build()
    }
}

extension User {
    final class Builder {
        // private(set)
        var id: String?
        var firstName: String?
        var middleName: String?
        var lastName: String?

        func setId(_ id: String) -> Self {
            self.id = id
            return self
        }

        func setFirstName(_ firstName: String) -> Self {
            self.firstName = firstName
            return self
        }

        func setMiddleName(_ middleName: String) -> Self {
            self.middleName = middleName
            return self
        }

        func setLastName(_ lastName: String) -> Self {
            self.lastName = lastName
            return self
        }

        func build() -> User? {
            return User(builder: self)
        }
    }
}

extension User.Builder {
    func setId1(_ id: String) {
        self.id = id
    }

    func setFirstName1(_ firstName: String) {
        self.firstName = firstName
    }

    func setMiddleName1(_ middleName: String) {
        self.middleName = middleName
    }

    func setLastName1(_ lastName: String) {
        self.lastName = lastName
    }

    func build1() -> User? {
        guard let id, let firstName, let lastName else {
            return nil
        }
        return User(id: id, firstName: firstName, lastName: lastName)
    }
}

// Declarative / By Function
if let user = User.Builder()
    .setId("1")
    .setFirstName("Yash")
    .setLastName("Vyas")
    .build() {
    debugPrint(user.fullName)
} else {
    debugPrint("User not created.")
}

// Block
if let user = User.make(builderBlock: { builder in
    builder.id = "1"
    builder.firstName = "Yash"
    builder.lastName = "Vyas"
}) {
    debugPrint(user.fullName)
} else {
    debugPrint("User not created.")
}

// Constructor Injection
let builder = User.Builder()
builder.setId1("1")
builder.setFirstName1("Yash")
builder.setLastName1("Vyas")
if let user = builder.build1() {
    debugPrint(user.fullName)
} else {
    debugPrint("User not created.")
}

// Property Injection
let builder1 = User.Builder()
builder1.id = "1"
builder1.firstName = "Yash"
builder1.lastName = "Vyas"
if let user = builder.build1() {
    debugPrint(user.fullName)
} else {
    debugPrint("User not created.")
}

//:[Next](@next)
