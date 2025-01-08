//
//  YV.swift
//  YVLearning
//
//  Created by Yash Vyas on 08/01/25.
//

import SwiftData

@available(iOS 17.0, *)
enum YV_ShemaMigrationPlan_02_00_00: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            YV_VersionedSchema_01_00_00.self,
            YV_VersionedSchema_02_00_00.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: YV_VersionedSchema_01_00_00.self,
                toVersion: YV_VersionedSchema_02_00_00.self
            )
        ]
    }
}

@available(iOS 17.0, *)
enum YV_VersionedSchema_02_00_00: VersionedSchema {
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
enum YV_VersionedSchema_01_00_00: VersionedSchema {
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
