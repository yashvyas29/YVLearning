# YVLearning Project Overview

YVLearning is a comprehensive Swift and SwiftUI playground project designed for experimenting with modern iOS development technologies. It serves as a living laboratory for testing new APIs, architectural patterns, and Swift language features.

## Key Technologies & Architecture
- **Language:** Swift 6.2+ (Modern Concurrency, `@Observable`, Strict Concurrency).
- **UI Framework:** SwiftUI (primarily), with a UIKit-based entry point (`AppDelegate`, `SceneDelegate`).
- **Data Persistence:** SwiftData with versioned schemas and migration plans.
- **Experimental Patterns:** MVI (Model-View-Intent) architecture, custom property wrappers for dependency injection, and advanced navigation patterns.
- **Target Platform:** iOS 26.0+ (as per project guidelines).

## Project Structure
- `YVLearning/App/`: Application entry points, delegates, and global schema definitions.
- `YVLearning/Views/`: A collection of SwiftUI views for various experiments (SwiftData, navigation, shapes, etc.).
- `YVLearning/Common/`: Shared utilities, UI components, networking (`ApiManager`), and architectural primitives (`MVIContainer`).
- `YVLearning/Extensions/`: Useful Swift and SwiftUI extensions.
- `YVLearning/Playgrounds/`: Xcode Playgrounds for isolated testing of Combine, SOLID principles, and concurrency.
- `YVLearningTests/`: Unit tests for core logic.

## Building and Running
The project is a standard Xcode project.

### Prerequisites
- Xcode 16+ (required for SwiftData and modern SwiftUI features).
- iOS 17.0+ Simulator or Device (though documentation suggests aiming for iOS 26.0 standards).

### Key Commands
- **Build:** Open `YVLearning.xcodeproj` and press `Cmd+B` or use:
  ```bash
  xcodebuild build -scheme YVLearning -project YVLearning.xcodeproj
  ```
- **Test:** Press `Cmd+U` in Xcode or use:
  ```bash
  xcodebuild test -scheme YVLearning -project YVLearning.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 15'
  ```

## Development Conventions
All contributions should adhere to the standards defined in `AGENTS.md`. Key highlights include:

- **Concurrency:** Exclusively use `async/await`. Avoid `DispatchQueue.main.async`.
- **State Management:** Use `@Observable` classes marked with `@MainActor`. Avoid legacy `ObservableObject`.
- **UI:**
  - Prefer `NavigationStack` over `NavigationView`.
  - Use `foregroundStyle()` instead of `foregroundColor()`.
  - Use modern `FormatStyle` API; avoid legacy `Formatter` subclasses.
  - Views should be broken into small, reusable `View` structs rather than computed properties.
- **SwiftData:**
  - Follow versioned schema patterns (`YV_VersionedSchema_XX_XX_XX`).
  - Properties must have default values or be optional (if CloudKit is intended).
- **Naming:** Follow strict Swift API Design Guidelines (camelCase, descriptive naming, appropriate argument labels).
- **Linting:** SwiftLint is used to enforce nesting limits and basic style rules. Ensure no warnings or errors before committing.
