---
# Database Patterns

**Project**: YVLearning
**Database**: SwiftData (on-device, encrypted storage)
**Data Access**: SwiftData `@Model` and `@Query` with versioned schemas
**Models Location**: `YVLearning/App/YVSwiftDataSchema.swift`, `YVLearning/Structs/`

---

## Connection Setup

```swift
// Source: YVLearning/App/YVSwiftDataSchema.swift:11-27
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
```

**Environment Variables**: None (on-device storage via SwiftData container)

---

## Data Access Pattern

**Pattern**: SwiftData models with `@Query` in views, `ModelContext` for modifications

```swift
// Source: YVLearning/App/YVSwiftDataSchema.swift:39-52
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
```

**To add new data access:**
1. Define `@Model` class in schema or as separate model
2. Access via `@Query` in SwiftUI views: `@Query var items: [Item]`
3. Modify via `ModelContext.insert(_:)`, `.delete(_:)`, or property mutations

---

## Entity/Model Definition

```swift
// Current model with relationships and conventions:
@Model
final class User {
    @Attribute(.unique) var key: Int
    var name: String

    init(key: Int, name: String) {
        self.key = key
        self.name = name
    }
}
```

**Conventions:**
| Aspect | Convention |
|--------|------------|
| Class structure | `@Model` decorator on class |
| Primary key | Custom unique `@Attribute(.unique)` or auto-id |
| Timestamps | Not enforced (add manually if needed) |
| Soft delete | Not used; delete directly |

---

## Relationships

SwiftData supports relationships between `@Model` classes:

```
[User] ──1:N──► [Task]     (One user has many tasks)
        ◄──────
```

Relationships defined by property references in `@Model` classes (no explicit decorator needed).

---

## Query Patterns

### Basic Operations

| Operation | Pattern |
|-----------|---------|
| Query all | `@Query var items: [Item]` in SwiftUI view |
| Find by ID | Manual filter in view or computed property |
| Create | `modelContext.insert(newItem)` |
| Update | Modify property directly, SwiftData auto-persists |
| Delete | `modelContext.delete(item)` |

### Filtering in Views

```swift
// Using @Query with filters
@Query(sort: \.name) var users: [User]

// Manual filtering in view logic
let filtered = users.filter { $0.key > 100 }
```

---

## Transactions

SwiftData handles transactions automatically within `ModelContext`. Multiple model changes within same context are atomic.

**Transaction boundaries managed at**: View/Service layer via `modelContext` implicit transaction.

**Rules in this codebase:**
- SwiftData auto-persists changes to properties marked with `@Model`
- Multiple inserts/deletes are handled atomically within same `ModelContext`

---

## Eager Loading / N+1 Prevention

SwiftData handles relationships efficiently by default. Relationships are loaded as needed.

**Syntax**: Direct property access on `@Model` objects automatically loads relationships.

---

## Versioning & Migrations

Versioned schemas enable backward-compatible database evolution:

```swift
// Source: YVLearning/App/YVSwiftDataSchema.swift
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
        init(name: String) { self.name = name }
    }
}

enum YV_VersionedSchema_02_00_00: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        .init(2, 0, 0)
    }

    @Model
    class User {
        @Attribute(.unique) var key: Int  // NEW field
        var name: String
        init(key: Int, name: String) { ... }
    }
}
```

| Action | Pattern |
|--------|---------|
| Create new schema version | Define new `enum VersionedSchema` with incremented version |
| Add migration | Add `MigrationStage` to `SchemaMigrationPlan` |
| Lightweight migration | Use `.lightweight()` for simple schema changes |
| Custom migration | Use `.custom()` for complex data transformations |

**Naming convention**: `YV_VersionedSchema_MM_mm_pp` (major_minor_patch)

---

## Error Handling

| Error Type | Handling |
|------------|----------|
| Model not found | Return optional or empty collection |
| Duplicate unique key | SwiftData throws error on insert |
| Relationship deleted | Relationship becomes nil or error |

Handle via `do/catch` when explicitly calling `modelContext` methods.

---

## Conventions Summary

| ✅ DO | ❌ DON'T |
|-------|----------|
| Define models as `@Model` classes | Use regular structs for persistent data |
| Query via `@Query` in views | Manual `ModelContext.fetch()` in views |
| Modify properties directly | Recreate objects for updates |
| Use versioned schemas | Ad-hoc database migrations |
| Handle relationships with nil checks | Assume relationships always exist |

---

## Quick Reference

| Need | Location | Pattern |
|------|----------|---------|
| Models/Entities | `YVLearning/App/YVSwiftDataSchema.swift` | `@Model` class |
| Queries | Views with `@Query` | `@Query var items: [Item]` |
| Mutations | ModelContext | `modelContext.insert(_:)` |
| Migrations | `YVSwiftDataSchema.swift` | `SchemaMigrationPlan` enum |
| DB Config | App setup | `.modelContainer(for: schema)` |

---
