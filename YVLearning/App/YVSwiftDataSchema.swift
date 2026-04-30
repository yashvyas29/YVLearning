//
//  YV.swift
//  YVLearning
//
//  Created by Yash Vyas on 08/01/25.
//

import SwiftData

@available(iOS 17.0, *)
enum YVShemaMigrationPlan020000: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            YVVersionedSchema010000.self,
            YVVersionedSchema020000.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: YVVersionedSchema010000.self,
                toVersion: YVVersionedSchema020000.self
            )
        ]
    }
}

@available(iOS 17.0, *)
enum YVVersionedSchema020000: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [User.self]
    }

    static var versionIdentifier: Schema.Version {
        .init(2, 0, 0)
    }

    @Model
    class User: CustomStringConvertible {
        @Attribute(.unique) var key: Int
        var name: String

        init(key: Int, name: String) {
            self.key = key
            self.name = name
        }

        var description: String {
            "\(String(describing: User.self)) \(#function)\n\(name)"
        }
    }
}

@available(iOS 17.0, *)
enum YVVersionedSchema010000: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [User.self]
    }

    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }

    @Model
    class User {
        @Attribute(.unique) var name: String

        init(name: String) {
            self.name = name
        }
    }
}
