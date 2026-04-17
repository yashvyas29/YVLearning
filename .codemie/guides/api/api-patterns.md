---
# API Patterns Guide

## Overview

**Project**: YVLearning
**Stack**: Swift 6.2+, Foundation URLSession
**Base URL**: Configured at call site in `ApiManager`

---

## File Structure

| Purpose | Path |
|---------|------|
| API Client | `YVLearning/Common/ApiManager.swift` |
| Error Types | `YVLearning/Common/ApiManager.swift:58-64` |
| Network Monitoring | `YVLearning/Common/NetworkMonitor.swift` |

---

## Endpoint Pattern

```swift
// Source: YVLearning/Common/ApiManager.swift:14-48
func request<D: Decodable, E: Encodable>(
    urlString: String,
    httpMethod: HTTPMethod = .get,
    type: D.Type,
    data: E? = nil
) async throws -> D {
    guard let url = URL(string: urlString) else {
        throw ApiError.invalidUrl
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = httpMethod.rawValue

    if let httpData = data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let httpBody = try? encoder.encode(httpData) {
            urlRequest.httpBody = httpBody
        }
    }

    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    // ... validation and decoding
    return try decoder.decode(D.self, from: data)
}
```

**To add new endpoint:**
1. Define request/response types in `YVLearning/Structs/`
2. Call `ApiManager.shared.request()` with generic types
3. Use `async/await` at call site, wrap in `do/catch` for error handling

---

## Error Handling

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

**Throw errors using**: Direct `throw ApiError.case` in `ApiManager`, or wrap in `do/catch` at call site.

**Usage:**
```swift
do {
    let result: MyResponseType = try await ApiManager.shared.request(
        urlString: "https://api.example.com/data",
        httpMethod: .get,
        type: MyResponseType.self
    )
    // Use result
} catch let error as ApiManager.ApiError {
    switch error {
    case .invalidUrl:
        // Handle invalid URL
    case .invalidStatusCode(let code):
        // Handle HTTP error codes
    case .failedToDecode:
        // Handle JSON decoding errors
    default:
        break
    }
}
```

---

## HTTP Methods

| Method | Usage |
|--------|-------|
| `GET` | Fetch data, default |
| `POST` | Create new resource, send data |
| `PUT` | Replace entire resource |
| `PATCH` | Update resource fields |
| `DELETE` | Remove resource |

```swift
// Access via:
urlRequest.httpMethod = HTTPMethod.post.rawValue
```

---

## Request/Response Handling

**Request encoding**: `JSONEncoder` with `keyEncodingStrategy = .convertToSnakeCase`
- Property: `userId` → JSON key: `user_id`

**Response decoding**: `JSONDecoder` with `keyDecodingStrategy = .convertFromSnakeCase`
- JSON key: `created_at` → Property: `createdAt`

**Status codes**: Accept `200...300` range (200-299 inclusive)

---

## Conventions

| Aspect | Convention Used |
|--------|-----------------|
| Async handling | `async/await` with `URLSession.shared.data(for:)` |
| Error strategy | Typed `ApiError` enum, throw early |
| Generic types | Generic parameters `<D: Decodable, E: Encodable>` |
| Singleton | `ApiManager.shared` static instance |

---

## Anti-Patterns

| ❌ Avoid | ✅ Use Instead | Reason |
|----------|----------------|--------|
| Callback-based URLSession API | `async/await` with `data(for:)` | Modern Swift concurrency |
| String interpolation in URL building | `URLComponents` or typed URL constants | Type safety, security |
| Silent error catching | Specific `catch` clauses or propagate | Visibility and debugging |
| Decoding in view layer | Decode in service, return typed objects | Separation of concerns |

---

## Quick Reference

| Task | Syntax | Example |
|------|--------|---------|
| Make GET request | `try await ApiManager.shared.request(url, type: T.self)` | `.codemie/guides/api/api-patterns.md:14` |
| Make POST request | `try await ApiManager.shared.request(url, httpMethod: .post, type: T.self, data: payload)` | Line 14-20 |
| Handle error | `catch let error as ApiError { ... }` | See Error Handling section |
| Access response | Decoded as generic type `D` | Direct usage after `try await` |

---
