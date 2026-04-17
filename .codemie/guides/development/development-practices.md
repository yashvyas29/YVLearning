---
# Development Practices

**Project**: YVLearning
**Language**: Swift 6.2+ | **Framework**: SwiftUI, SwiftData
**Linter**: SwiftLint (`.swiftlint.yml`) | **Formatter**: Swift format (conventions)

---

## Code Style

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | PascalCase | `ApiManager.swift`, `FormFieldValidation.swift` |
| Classes | PascalCase | `User`, `ApiManager` |
| Functions | camelCase | `request()`, `validate()` |
| Variables | camelCase | `urlString`, `httpMethod` |
| Constants | UPPER_SNAKE_CASE or camelCase | `HTTPMethod.get` |
| Private | Leading underscore or private keyword | `private let value` |

### File Organization

```swift
// Source: YVLearning/Common/ApiManager.swift
// Standard file structure in this codebase:

import Foundation

struct ApiManager {
    // MARK: - Properties
    static let shared = ApiManager()

    // MARK: - Public Methods
    func request<D: Decodable, E: Encodable>(...) async throws -> D { }

    // MARK: - Private Methods
    private func validateResponse(...) { }

    // MARK: - Nested Types
    enum HTTPMethod: String { }
    enum ApiError: Error { }
}
```

### Import Order

```swift
// 1. System frameworks
import Foundation
import SwiftUI
import SwiftData

// 2. External packages (if any)

// 3. Internal modules (@testable for tests)
@testable import YVLearning
```

---

## Code Quality

### Commands

| Action | Command | Auto-fix |
|--------|---------|----------|
| Lint | `swiftlint` | `swiftlint --fix` |
| Format | Xcode: `Editor → Format Code` or `Cmd+A, Cmd+I` | Auto via Xcode |
| Type check | Built-in to Swift compiler | - |
| Build | `xcodebuild build -scheme YVLearning` | - |

### Configuration Files

| Tool | Config File |
|------|-------------|
| Linter | `.swiftlint.yml` |
| Type checker | Swift compiler (implicit) |

### SwiftLint Rules

```yaml
# Source: .swiftlint.yml
nesting:
  type_level:
    warning: 2  # Nested types warning at depth 2
    error: 3    # Error at depth 3
  function_level:
    warning: 2
    error: 3
```

**Implications**: Don't deeply nest types/functions. Flatten structure if approaching limits.

---

## Error Handling

### Exception Types

```swift
// Source: YVLearning/Common/ApiManager.swift:58-64
enum ApiError: Error {
    case invalidUrl
    case invalidResponse
    case invalidStatusCode(Int)
    case failedToLoadData(Error)
    case failedToDecode(Error)
}
```

| Exception | Use When |
|-----------|----------|
| `ApiError.invalidUrl` | URL construction fails |
| `ApiError.invalidStatusCode(Int)` | HTTP response code outside 200-299 |
| `ApiError.failedToDecode(Error)` | JSON decoding fails |

### Pattern

```swift
// Source: YVLearning/Common/ApiManager.swift:30-46
do {
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
        throw ApiError.invalidResponse
    }
    guard 200...300 ~= statusCode else {
        throw ApiError.invalidStatusCode(statusCode)
    }
    return try decoder.decode(D.self, from: data)
} catch let error {
    throw ApiError.failedToLoadData(error)
}
```

**Rules:**
- Throw specific errors from `ApiError` enum
- Catch and wrap lower-level errors for context
- ❌ Never silently catch and ignore errors

---

## Logging

### Setup

```swift
// Source: YVLearning/App/AppDelegate.swift
import os.log

extension OSLog {
    static let appCycle = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "appCycle")
}
```

### Usage Pattern

```swift
// Source: YVLearning/App/AppDelegate.swift
Logger.appCycle.debug("didFinishLaunchingWithOptions")
Logger.appCycle.info("By \("Yash", privacy: .private)")
os_log(.info, "didFinishLaunchingWithOptions")
```

### Levels

| Level | Use For |
|-------|---------|
| `debug` | Development troubleshooting, detailed diagnostics |
| `info` | Significant operations (app launch, user actions) |
| `warn` | Recoverable issues, deprecations |
| `error` | Failures requiring attention |

### Rules

- ✅ Include context: `userId`, `requestId`, `feature name`
- ✅ Use `Logger` from `os` framework for structured logging
- ❌ No secrets, passwords, or sensitive tokens in logs
- ❌ Avoid excessive logging in loops or hot code paths

---

## Async Patterns

**Style**: Exclusively `async/await` (Swift 6.2+)

```swift
// Source: YVLearning/Common/ApiManager.swift:14-48
func request<D: Decodable, E: Encodable>(
    urlString: String,
    httpMethod: HTTPMethod = .get,
    type: D.Type,
    data: E? = nil
) async throws -> D {
    // Uses async/await URLSession API
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try decoder.decode(D.self, from: data)
}
```

### Error Handling in Async

```swift
do {
    let result = try await ApiManager.shared.request(...)
    // Process result
} catch let error as ApiError {
    // Handle API-specific errors
    print("API error: \(error)")
} catch {
    // Handle other errors
    print("Unexpected error: \(error)")
}
```

---

## Dependencies

### Adding Dependencies

Since this is a SwiftUI/SwiftData playground, avoid third-party dependencies unless approved.

**Built-in frameworks** (prefer):
- `Foundation` - Core utilities
- `SwiftUI` - UI framework
- `SwiftData` - Persistence
- `Combine` - Reactive programming (see Playgrounds)

### Update Process

No external package manager (no CocoaPods, SPM packages). All dependencies are built-in.

---

## Git Workflow

### Branch Naming

```
feature/[description]
bugfix/[description]
```

**Examples**: `feature/add-form-validation`, `bugfix/fix-api-timeout`

### Commit Messages

```
[type]: [description]

[body - optional]
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

**Example**: `feat: add form field validation property wrapper`

### Pre-commit Checklist

- [ ] Linting passes: `swiftlint` (no warnings)
- [ ] Tests pass: `xcodebuild test -scheme YVLearning`
- [ ] Build succeeds: `xcodebuild build -scheme YVLearning`
- [ ] No Swift 6 concurrency warnings

---

## Common Patterns

| Pattern | When to Use | Example |
|---------|-------------|---------|
| `@Inject<T>` | Dependency resolution in view models | `YVLearning/Common/InjectPropertyWrapper.swift:10` |
| `@FormFieldValidation` | Input field validation with rules | `YVLearning/Common/FormFieldValidation.swift:10` |
| `@Model` | Persistent SwiftData entities | `YVLearning/App/YVSwiftDataSchema.swift:39` |
| `@Observable` | SwiftUI view model state | Views with state management |
| `ApiManager.shared` | Singleton HTTP client | API calls in services |

---

## Don't Do

| ❌ Avoid | ✅ Instead | Why |
|----------|-----------|-----|
| Computed view properties | Separate `View` structs | Prevents excessive nesting (SwiftLint) |
| Callbacks/closures | `async/await` | Modern concurrency model |
| String interpolation in URLs | `URLComponents` or typed URLs | Type safety and security |
| `DispatchQueue.main.async` | Swift concurrency (already on main via `@MainActor`) | Cleaner async model |
| Force unwrap `!` | Optional binding or guard | Crash prevention |

---

## Quick Reference

| Need | Location |
|------|----------|
| Linter config | `.swiftlint.yml` |
| API client | `YVLearning/Common/ApiManager.swift` |
| Error types | `YVLearning/Common/ApiManager.swift:58-64` |
| Logger setup | `YVLearning/App/AppDelegate.swift` |
| Validation rules | `YVLearning/Common/FormFieldValidation.swift:78-84` |
| DI resolver | `YVLearning/Common/InjectPropertyWrapper.swift` |

---
