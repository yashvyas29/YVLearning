# CLAUDE.md

**Purpose**: AI-optimized execution guide for Claude Code agents working with YVLearning codebase

---

## 🚨 CRITICAL RULES (Check Every Task)

| Rule | Trigger | Action |
|------|---------|--------|
| **Check Guides First** | ANY task/prompt | ALWAYS check relevant guides BEFORE searching codebase |
| **Testing** | User says "test", "write tests", "run tests" | Use testing guide, ensure tests pass before committing |
| **Build Verification** | After code changes | Run `xcodebuild build -scheme YVLearning` |
| **Linting** | Before commits | Run `swiftlint` and fix warnings |
| **Shell** | ANY shell command | ONLY bash/macOS syntax |

**Recovery**: If stuck → Check [Troubleshooting](#-troubleshooting)

---

## 📚 GUIDE IMPORTS

| Category | Guide Path | Purpose |
|----------|------------|---------|
| Architecture | `.codemie/guides/architecture/architecture.md` | MVI patterns, dependency injection, property wrappers, module structure |
| API Development | `.codemie/guides/api/api-patterns.md` | REST client patterns, ApiManager, async/await, error handling |
| Data & Database | `.codemie/guides/data/database-patterns.md` | SwiftData models, versioned schemas, migrations, persistence |
| Testing | `.codemie/guides/testing/testing-patterns.md` | XCTest patterns, unit tests, fixtures, async testing |
| Development Practices | `.codemie/guides/development/development-practices.md` | Code style, error handling, logging, async patterns, conventions |
| Security | `.codemie/guides/security/security-patterns.md` | Input validation, form validation rules, data security |

---

## ⚡ TASK CLASSIFIER

**Analyze request intent → Match category → Load appropriate guides**

| Category | User Intent / Purpose | Example Requests | P0 Guide |
|----------|----------------------|------------------|----------|
| **Architecture** | System structure, design decisions, planning features, module organization | "How should I structure this feature?", "Where should this go?", "Explain the app architecture" | `.codemie/guides/architecture/architecture.md` |
| **API Development** | Creating/modifying API calls, networking, HTTP requests | "Create API call for...", "How do I fetch data from API?", "Add endpoint handler" | `.codemie/guides/api/api-patterns.md` |
| **Data & Database** | Database operations, SwiftData models, persistence, queries | "Create a data model", "How do I save data?", "Query database" | `.codemie/guides/data/database-patterns.md` |
| **Testing** | Writing tests, running tests, test coverage, unit tests | "Write tests for...", "Fix failing test", "Run test suite" | `.codemie/guides/testing/testing-patterns.md` |
| **Development Practices** | Code quality, error handling, logging, naming conventions, async patterns | "How do I handle errors?", "Add logging", "Follow the conventions", "Make this async" | `.codemie/guides/development/development-practices.md` |
| **Security** | Input validation, form validation, data security, protecting sensitive data | "Validate user input", "Add form validation", "Secure this field" | `.codemie/guides/security/security-patterns.md` |

---

## 🛠️ PROJECT COMMANDS

| Action | Command |
|--------|---------|
| **Build** | `xcodebuild build -scheme YVLearning -project YVLearning.xcodeproj` |
| **Build (Xcode)** | Open `YVLearning.xcodeproj` and press `Cmd+B` |
| **Run Tests** | `xcodebuild test -scheme YVLearning -project YVLearning.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 15'` |
| **Run Tests (Xcode)** | Press `Cmd+U` in Xcode |
| **Run Single Test** | `xcodebuild test -scheme YVLearning -only-testing YVLearningTests/<TestClassName>/<testMethodName>` |
| **Lint Check** | `swiftlint` |
| **Fix Linting Issues** | `swiftlint --fix` |
| **Format Code** | `Cmd+A` then `Cmd+I` in Xcode (or `Editor → Format Code`) |
| **Clean Build** | `xcodebuild clean -scheme YVLearning` |

---

## 📱 PROJECT CONTEXT

### Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Language | Swift | 6.2+ (strict concurrency) |
| UI Framework | SwiftUI | iOS 17.0+ |
| Persistence | SwiftData | iOS 17.0+ |
| Data Models | Swift `@Model` classes | - |
| HTTP Client | Foundation URLSession | async/await |
| Testing | XCTest | Native |
| Linter | SwiftLint | Nesting limits enforced |
| API Approach | RESTful with async/await | JSON encoding/decoding |

### Project Structure

```
YVLearning/
├── App/                      Entry points, delegates, SwiftData schemas
├── Views/ (23 files)         SwiftUI view components and features
├── Common/ (25 files)        Utilities, ApiManager, UI components, DI
├── Extensions/               Helper methods for Swift/SwiftUI
├── Structs/                  Data models, value types, validation rules
├── ViewModifiers/            Custom SwiftUI modifiers
├── Protocols/                Protocol definitions
├── AppIntents/               Siri Shortcuts integration
├── Localization/             String catalogs
├── Playgrounds/              Isolated experimentation
└── YVLearningTests/          Unit tests
```

### Key Patterns in Codebase

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Dependency Injection** | `YVLearning/Common/InjectPropertyWrapper.swift` | `@Inject<T>` property wrapper for component resolution |
| **Form Validation** | `YVLearning/Common/FormFieldValidation.swift` | Property wrapper for declarative field validation |
| **API Client** | `YVLearning/Common/ApiManager.swift` | Singleton REST client with async/await |
| **SwiftData Schema** | `YVLearning/App/YVSwiftDataSchema.swift` | Versioned models with migration support |
| **Factory** | `YVLearning/Common/Factory.swift` | Service/component factory for building instances |
| **Logging** | `YVLearning/App/AppDelegate.swift` | `Logger` and `os_log` for structured logging |

---

## 🔧 DEVELOPMENT WORKFLOW

### Before Starting

1. Check relevant guide from GUIDE IMPORTS section above
2. Review recent commits to understand conventions: `git log --oneline -10`
3. Run build to verify setup: `xcodebuild build -scheme YVLearning`

### Writing Code

1. Follow naming conventions from [Development Practices Guide](.codemie/guides/development/development-practices.md)
2. Use `async/await` for concurrency (never `DispatchQueue.main.async`)
3. Use `@Observable` for view state (never `ObservableObject`)
4. Validate input using `@FormFieldValidation` property wrapper
5. Handle errors with typed `Error` enums

### Before Committing

1. Run linting: `swiftlint`
2. Run tests: `xcodebuild test -scheme YVLearning`
3. Verify build: `xcodebuild build -scheme YVLearning`
4. Check file organization (no computed view properties, break into View structs)

### Commit Message Format

```
[type]: [description]

[body - optional]
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

---

## ⚠️ TROUBLESHOOTING

### Build Failures

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot find 'User' in scope` | SwiftData model not accessible | Ensure model is in `YVSwiftDataSchema.swift` and schema is current |
| Concurrency warning | Non-isolated mutation | Mark `@Observable` class with `@MainActor` |
| Type mismatch in API call | Generic parameter mismatch | Verify request/response types implement `Codable` |
| Nesting depth error | SwiftLint violation | Break nested types into separate files (max depth: 2 warning, 3 error) |

### Test Failures

| Error | Solution |
|-------|----------|
| `Could not find test bundle` | Ensure target membership includes test class |
| Async timeout | Increase `wait(for:timeout:)` timeout or check await syntax |
| Mock not working | Verify import path matches actual module location |

### Runtime Issues

| Issue | Solution |
|-------|----------|
| API call fails silently | Check error handling - ensure no catch-and-ignore blocks |
| Form validation not showing errors | Access via projected value `$fieldName` in view |
| SwiftData model not persisting | Verify mutations happen on main thread (use `@MainActor`) |
| Logger not appearing in console | Check log level (Xcode console can filter by level) |

### Common Questions

**Q: How do I add a new API endpoint?**
A: See [API Development Guide](.codemie/guides/api/api-patterns.md) - define types, call `ApiManager.shared.request()`

**Q: How do I create a new data model?**
A: See [Database Patterns Guide](.codemie/guides/data/database-patterns.md) - add `@Model` class to schema

**Q: How do I validate user input?**
A: See [Security Guide](.codemie/guides/security/security-patterns.md) - use `@FormFieldValidation` wrapper

**Q: How should I structure a new feature?**
A: See [Architecture Guide](.codemie/guides/architecture/architecture.md) - follow MVI patterns, organize by feature

**Q: How do I test this code?**
A: See [Testing Guide](.codemie/guides/testing/testing-patterns.md) - use XCTest, follow naming conventions

---

## 📋 ARCHITECTURE DECISION RECORDS

### Why SwiftUI + SwiftData?

Modern Swift framework combination providing:
- Type-safe UI with reactive state management
- Built-in persistence with encryption
- First-class async/await support
- iOS 17+ target enables latest APIs

### Why Modular Organization?

Enables:
- Feature-based development workflows
- Clear separation between UI and business logic
- Easier testing and code reuse
- Support for experimentation with new patterns

### Why Custom Property Wrappers?

Provide:
- Lightweight dependency injection without external libraries
- Declarative form validation with error messaging
- Custom state management patterns

---

## 🎯 QUALITY GATES

### Before Each Commit

- [ ] `swiftlint` passes (no warnings/errors)
- [ ] All tests pass: `xcodebuild test -scheme YVLearning`
- [ ] Build succeeds: `xcodebuild build -scheme YVLearning`
- [ ] Code follows conventions from [Development Practices Guide](.codemie/guides/development/development-practices.md)
- [ ] New features have corresponding tests
- [ ] Git branch follows naming convention: `feature/` or `bugfix/`

---

## 🔐 Security Checklist

- [ ] Form inputs validated using `@FormFieldValidation`
- [ ] API responses handled with typed errors
- [ ] No hardcoded secrets or API keys
- [ ] SwiftData models use appropriate access controls
- [ ] No `force try` or `force unwrap` in production code

---

## 📞 QUICK LINKS

- **Architecture Guide**: `.codemie/guides/architecture/architecture.md`
- **API Development**: `.codemie/guides/api/api-patterns.md`
- **Data & Database**: `.codemie/guides/data/database-patterns.md`
- **Testing Patterns**: `.codemie/guides/testing/testing-patterns.md`
- **Development Practices**: `.codemie/guides/development/development-practices.md`
- **Security**: `.codemie/guides/security/security-patterns.md`
- **Project Config**: `AGENTS.md`, `GEMINI.md`, `.swiftlint.yml`

---
