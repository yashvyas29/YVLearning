---
# Testing Patterns

**Project**: YVLearning
**Framework**: XCTest (native iOS testing)
**Test Location**: `YVLearningTests/` directory
**Test Plan**: `YVLearning.xctestplan`

---

## Test Organization

```
YVLearningTests/
├── YVLearningTests.swift          Main test suite
└── Structs/
    └── LearnTaskTest.swift        Struct-specific tests
```

### Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| Test files | `[Target]Tests.swift` or `[Module]Test.swift` | `YVLearningTests.swift`, `LearnTaskTest.swift` |
| Test functions | `test[Feature]()` | `testUserCreation()`, `testFormValidation()` |
| Test classes | `[Target]Tests` or `[Feature]Tests` | `YVLearningTests` |

---

## Running Tests

| Action | Command |
|--------|---------|
| All tests | `xcodebuild test -scheme YVLearning -project YVLearning.xcodeproj` |
| Unit only | `xcodebuild test -scheme YVLearning` |
| Single file | `xcodebuild test -scheme YVLearning -only-testing YVLearningTests/YVLearningTests` |
| Single test | `xcodebuild test -scheme YVLearning -only-testing YVLearningTests/YVLearningTests/testName` |
| With coverage | `xcodebuild test -scheme YVLearning -enableCodeCoverage YES` |

Or press `Cmd+U` in Xcode to run all tests in scheme.

---

## Unit Test Pattern

```swift
// Source: YVLearningTests/Structs/LearnTaskTest.swift
import XCTest
@testable import YVLearning

class LearnTaskTest: XCTestCase {
    var sut: LearnTask!  // System Under Test

    override func setUp() {
        super.setUp()
        sut = LearnTask(title: "Test", completed: false)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testTaskInitialization() {
        XCTAssertEqual(sut.title, "Test")
        XCTAssertFalse(sut.completed)
    }
}
```

### Structure

```swift
// Standard test structure in this codebase:
class [Feature]Tests: XCTestCase {
    override func setUp() {
        // Arrange - setup test data
        super.setUp()
    }

    override func tearDown() {
        // Cleanup
        super.tearDown()
    }

    func test[Scenario]() {
        // Arrange
        // Act
        // Assert
    }
}
```

---

## Fixtures / Test Data

XCTest uses `setUp()` for per-test initialization and `setUpWithError()` for failure handling.

### Setup Pattern

```swift
override func setUp() {
    super.setUp()
    // Create test fixtures
    sut = LearnTask(title: "Test Task", completed: false)
}
```

### Common Fixtures

| Fixture | Purpose | Usage |
|---------|---------|-------|
| `sut` | System Under Test | The object being tested |
| Test data objects | Mock model instances | Initialize with known values |
| Test URLs | API endpoints for testing | Hardcoded constants |

---

## Async Testing

```swift
// For async/await functions
func testAsyncOperation() async throws {
    let result = try await asyncFunction()
    XCTAssertNotNil(result)
}

// Or use expectation for callbacks
func testAsyncCallback() {
    let expectation = XCTestExpectation(description: "async operation")

    asyncFunction { result in
        XCTAssertNotNil(result)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}
```

**Pattern**: Use `async/await` functions directly in XCTest, or use `XCTestExpectation` for callback-based APIs.

---

## Common Assertions

| Assertion | Usage |
|-----------|-------|
| `XCTAssertEqual(a, b)` | Verify equality |
| `XCTAssertTrue/False(value)` | Boolean assertions |
| `XCTAssertNil/NotNil(value)` | Nil checks |
| `XCTAssertThrowsError` | Error throwing |
| `XCTFail("message")` | Explicit failure |

---

## Writing New Tests

### Checklist

1. Create test class: `class [Feature]Tests: XCTestCase`
2. Import module: `@testable import YVLearning`
3. Setup fixtures in `setUp()`
4. Follow naming: `test[Feature][Scenario]()`
5. Run to verify: `xcodebuild test -only-testing YVLearningTests/[Class]/test[Name]`

### Template

```swift
import XCTest
@testable import YVLearning

class NewFeatureTests: XCTestCase {
    var sut: FeatureUnderTest!

    override func setUp() {
        super.setUp()
        sut = FeatureUnderTest()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testBasicFunctionality() {
        // Arrange
        let input = "test"

        // Act
        let result = sut.process(input)

        // Assert
        XCTAssertEqual(result, "expected")
    }
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tests interfering | Ensure `setUp()` creates fresh fixtures |
| Async timeout | Increase `wait(for:timeout:)` timeout value |
| Module not found | Verify `@testable import YVLearning` and target membership |
| State pollution | Always reset state in `tearDown()` |
| Flaky tests | Ensure no time-dependent logic or use `XCTestExpectation` |

---

## Quick Reference

| Need | Location |
|------|----------|
| Test config | `YVLearning.xctestplan` |
| Test target | `YVLearningTests` build target |
| Test utilities | XCTest framework assertions |
| Example tests | `YVLearningTests/`, `YVLearningTests/Structs/LearnTaskTest.swift` |

---
