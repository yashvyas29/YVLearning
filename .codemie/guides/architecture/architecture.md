---
# Architecture Guide

**Project**: YVLearning
**Style**: Modular with MVI (Model-View-Intent) experimentation
**Language**: Swift 6.2+ | **Framework**: SwiftUI, SwiftData

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    App Entry Points                       │
│         (AppDelegate, SceneDelegate, UIWindow)           │
└────────────────────────┬────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
    ┌───▼─────┐                     ┌────▼────┐
    │  Views  │                     │  Common  │
    │ (SwiftUI)                     │(Utilities)
    └─────────┘                     └──────────┘
        │                                 │
        │       ┌──────────────────────┐  │
        │       │  Extensions          │  │
        │       │  (Helpers)           │  │
        │       └──────────────────────┘  │
        │                                 │
        └────────────┬────────────────────┘
                     │
        ┌────────────▼────────────┐
        │  Data Persistence       │
        │  (SwiftData, Models)    │
        └─────────────────────────┘
```

**Key Decision**: Modular organization by feature/concern with shared utilities layer, enabling experimentation with modern Swift/SwiftUI patterns while maintaining clear separation of concerns.

---

## Component Structure

```
YVLearning/
├── App/                      Entry points, delegates, SwiftData schemas
├── Views/                    SwiftUI view components (23 files)
├── Common/                   Utilities, services, UI components (25 files)
├── Extensions/              Helper extensions for Swift/SwiftUI
├── Playgrounds/             Isolated testing (Combine, concurrency, SOLID)
├── Structs/                 Data models and value types
├── ViewModifiers/           Custom SwiftUI modifiers
├── Protocols/               Protocol definitions
├── AppIntents/              Siri Shortcuts definitions
└── Localization/            String catalogs and localization
```

---

## Design Patterns Detected

| Pattern | Usage | Location |
|---------|-------|----------|
| **Dependency Injection** | Custom `@Inject` property wrapper for component resolution | `YVLearning/Common/InjectPropertyWrapper.swift:10-16` |
| **Singleton** | `ApiManager.shared`, `Resolver.shared`, `Factory` | `YVLearning/Common/ApiManager.swift:11` |
| **Property Wrapper** | Form validation, injection, custom state management | `YVLearning/Common/FormFieldValidation.swift:10-11` |
| **Factory** | `Factory.swift` for building UI components and services | `YVLearning/Common/Factory.swift` |
| **Observer** | `@Observable` classes for SwiftUI state (modern, not `ObservableObject`) | `YVLearning/App/` (swiftData Models) |
| **Strategy** | Form validation rules enum for flexible validation logic | `YVLearning/Common/FormFieldValidation.swift:78-84` |

### Primary Pattern: Custom Property Wrapper for Dependency Injection

```swift
// Source: YVLearning/Common/InjectPropertyWrapper.swift:10-17
@propertyWrapper
struct Inject<Component> {
    let wrappedValue: Component

    init() {
        self.wrappedValue = Resolver.shared.resolve(Component.self)
    }
}
```

**When to use**: For constructor-free dependency resolution in view models, services, or components. Enables loose coupling without service locator anti-patterns.

---

## Layer/Module Responsibilities

| Component | Responsibility | Depends On | Depended By |
|-----------|----------------|------------|-------------|
| **App** | Application lifecycle, delegates, data schema management | Foundation, SwiftData | Views, all features |
| **Views** | SwiftUI user interface, presentation logic | Common, Structs, SwiftUI | App entry point |
| **Common** | ApiManager, utilities, shared UI components, DI resolver | Foundation, SwiftUI | All Views, App |
| **Extensions** | Swift/SwiftUI helper methods | Foundation, SwiftUI | Views, Common |
| **Structs** | Data models, value types, validation rules | Foundation | Views, Common, Playgrounds |
| **Playgrounds** | Isolated experimentation, no runtime dependencies | Foundation, Combine | None (dev only) |

---

## Dependency Rules

```
Views ──► Common ──► Extensions
           │
           ▼
    Foundation/SwiftUI
           │
           ▼
    SwiftData Models (Structs)
```

| Rule | Enforced By |
|------|-------------|
| Views never import App directly | Convention / Module boundary |
| Common utilities have no SwiftUI dependencies (mostly) | Convention / file separation |
| SwiftData models stay in Structs or App | Convention / data layer |
| Extensions only enhance existing types | Convention / file organization |

**Violations to avoid:**
- ❌ Circular dependencies between modules
- ❌ Direct database queries in View files
- ❌ Mixing business logic in SwiftUI views

---

## Data Flow

```
User Interaction (View)
        │
        ▼
    [View calls method on ViewModel/@Observable]
        │
        ▼
    [Service/ViewModel processes request]
        │
        ├─► [ApiManager for remote calls]
        │
        └─► [SwiftData for persistence]
        │
        ▼
    [Update @Observable state]
        │
        ▼
    [SwiftUI re-renders with new state]
```

**Example flow** (API request):
1. User taps button in `View`
2. View calls method on `@Observable` ViewModel
3. ViewModel calls `ApiManager.shared.request(...)`
4. ApiManager handles async HTTP request, throws `ApiError` on failure
5. ViewModel catches error or updates state
6. SwiftUI re-renders with new data

---

## Key Abstractions

| Abstraction | Purpose | Implementations |
|-------------|---------|-----------------|
| `@Inject<Component>` | Dependency resolution | `Resolver.resolve(_:)` |
| `@FormFieldValidation` | Declarative field validation with error messages | Multiple validation rules (email, password, custom regex) |
| `ApiManager` | HTTP client with typed requests/responses | Static `shared` instance |
| `@Observable` | Modern SwiftUI state management | Custom view models in Views |

```swift
// Source: YVLearning/Common/FormFieldValidation.swift:10-30
@propertyWrapper
struct FormFieldValidation {
    private var value: String
    private let rule: FormFieldValidationRule
    var errorMessage: String?

    init(wrappedValue initialValue: String, rule: FormFieldValidationRule) {
        self.value = initialValue
        self.rule = rule
        self.errorMessage = validate()
    }

    var wrappedValue: String {
        get { value }
        set {
            value = newValue
            errorMessage = validate()
        }
    }
}
```

---

## Adding New Features

### To add new View/Feature:

1. **Create View**: Add file in `YVLearning/Views/FeatureNameView.swift`
2. **Create ViewModel** (if needed): Add `@Observable` class in same file or separate file
3. **Add Model**: Create struct in `YVLearning/Structs/` if new data type
4. **Wire up**: Use `@Environment`, `@Bindable`, or `@State` to pass state
5. **Add tests**: Create test in `YVLearningTests/Structs/` for business logic

### To add new API endpoint:

1. Create function in `ApiManager` or extend with specific method
2. Define request/response types in `Structs/`
3. Call from ViewModel using `async/await`: `let data = try await ApiManager.shared.request(...)`
4. Handle `ApiError` appropriately

### To add new SwiftData model:

1. Create `@Model` class in SwiftData schema (`YVLearning/App/YVSwiftDataSchema.swift`)
2. Create versioned schema if modifying existing schema
3. Add migration stage to `SchemaMigrationPlan` if needed
4. Access via `@Query` in views or via `ModelContext`

---

## Configuration & Environment

| Config Type | Location | Accessed Via |
|-------------|----------|--------------|
| App constants | `Info.plist`, `YVLearning.entitlements` | Bundle properties |
| API base URL | Hardcoded or `ApiManager` | `ApiManager` struct |
| SwiftData schema | `YVLearning/App/YVSwiftDataSchema.swift` | `modelContainer` modifier |
| Feature flags | None (experimentation repo) | - |

---

## Boundaries Summary

| ✅ DO | ❌ DON'T |
|-------|----------|
| Use `@Observable` for shared state | Use legacy `ObservableObject` |
| Async/await for concurrency | GCD `DispatchQueue` |
| Break views into small `View` structs | Use computed properties for views |
| Use `@Inject` for dependency resolution | Create instances manually everywhere |
| Define validation rules in `FormFieldValidationRule` | Inline regex validation in views |
| Access SwiftData via `@Query` in views | Raw `ModelContext` queries in views |

---

## Quick Reference

| Need | Location | Pattern |
|------|----------|---------|
| Entry point | `YVLearning/App/AppDelegate.swift` | UIApplicationDelegate |
| Main window | `YVLearning/App/SceneDelegate.swift` | UIWindowSceneDelegate |
| API client | `YVLearning/Common/ApiManager.swift` | Singleton with `async` methods |
| Data models | `YVLearning/App/YVSwiftDataSchema.swift` | `@Model` classes |
| Shared utilities | `YVLearning/Common/` | Factory, helpers, validators |
| DI resolver | `YVLearning/Common/InjectPropertyWrapper.swift` | `@Inject` property wrapper |
| UI components | `YVLearning/Common/` | Reusable button styles, views |

---
