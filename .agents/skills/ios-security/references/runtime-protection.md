# Runtime Protection

Covers `JailbreakDetectionManager`, `DebugDetectionManager`, and `ReverseEngineeringDetector`.

All three are `struct` with a protocol + `static let shared` pattern.
All checks are synchronous and read-only — no side effects.

---

## JailbreakDetectionManager

**Location:** `YVLearning/Common/Security/JailbreakDetectionManager.swift`
**Protocol:** `JailbreakDetecting`

### Key APIs

```swift
let detector = JailbreakDetectionManager.shared

// Quick boolean gate
if detector.isJailbroken { ... }

// Full indicator list (for analytics/logging)
let indicators = detector.detectedIndicators
// → [.suspiciousFilePath, .sandboxViolation]
```

### Indicators

| Case | Detection Method | False Positive Risk |
|------|-----------------|---------------------|
| `.suspiciousFilePath` | `FileManager.fileExists` for 16 known jailbreak paths | Low |
| `.sandboxViolation` | Write test to `/private/jailbreak-probe-<UUID>` | None |
| `.applicationsSymlink` | `attributesOfItem(atPath: "/Applications")` — checks `.typeSymbolicLink` | None |
| `.dylibInjection` | `DYLD_INSERT_LIBRARIES` env var | Low |

### Integration Pattern

```swift
#if !DEBUG
func checkDeviceIntegrity() -> Bool {
    let jailbreak = JailbreakDetectionManager.shared
    guard !jailbreak.isJailbroken else {
        // Log to analytics — don't crash
        Analytics.log(.jailbreakDetected, metadata: jailbreak.detectedIndicators.map(\.rawValue))
        return false
    }
    return true
}
#endif
```

### Adding cydia:// URL Scheme Check

The URL scheme check requires `"cydia"` in `LSApplicationQueriesSchemes` (Info.plist)
and must run on the main thread:

```swift
// In Info.plist, add:
// <key>LSApplicationQueriesSchemes</key>
// <array><string>cydia</string></array>

@MainActor
func hasCydiaScheme() -> Bool {
    guard let url = URL(string: "cydia://package/com.example") else { return false }
    return UIApplication.shared.canOpenURL(url)
}
```

---

## DebugDetectionManager

**Location:** `YVLearning/Common/Security/DebugDetectionManager.swift`
**Protocol:** `DebugDetecting`

### Key APIs

```swift
let detector = DebugDetectionManager.shared

// Is a debugger attached? (excludes simulator)
if detector.isDebugged { ... }

// Running in simulator?
if detector.isRunningOnSimulator { ... }

// All indicators (include simulator flag)
let indicators = detector.detectedIndicators
```

### Indicators

| Case | Detection Method | Always triggers in |
|------|-----------------|-------------------|
| `.debuggerAttached` | `sysctl(KERN_PROC_PID)` — P_TRACED flag | Xcode debug runs |
| `.ttyAttached` | `isatty(STDIN_FILENO/STDOUT_FILENO/STDERR_FILENO)` | Xcode console |
| `.simulator` | `SIMULATOR_DEVICE_NAME` env var | iOS Simulator |

### Integration Pattern

```swift
#if !DEBUG
guard !DebugDetectionManager.shared.isDebugged else {
    // Disable sensitive feature rather than crashing
    sensitiveFeatureEnabled = false
    return
}
#endif
```

### Combining Jailbreak + Debug Detection

```swift
#if !DEBUG
func isEnvironmentTrusted() -> Bool {
    !JailbreakDetectionManager.shared.isJailbroken &&
    !DebugDetectionManager.shared.isDebugged &&
    !ReverseEngineeringDetector.shared.isUnderAttack
}
#endif
```

---

## ReverseEngineeringDetector

**Location:** `YVLearning/Common/Security/ReverseEngineeringDetector.swift`
**Protocol:** `ReverseEngineeringDetecting`

### Key APIs

```swift
let detector = ReverseEngineeringDetector.shared

if detector.isUnderAttack { ... }

let indicators = detector.detectedIndicators
// → [.fridaDetected, .fridaPortOpen]
```

### Indicators

| Case | Detection | Notes |
|------|-----------|-------|
| `.fridaDetected` | Dylib scan: `frida`, `gadget` | Fails if gadget renamed |
| `.hookingLibrary` | Dylib scan: `substrate`, `substitute`, `libhooker` | |
| `.sslBypass` | Dylib scan: `sslkillswitch` | Active SSL bypass tool |
| `.uiInspectionTool` | Dylib scan: `revealserver` | |
| `.cycriptDetected` | Dylib scan: `cynject`, `cycript` | |
| `.fridaPortOpen` | TCP connect to `127.0.0.1:27042` (non-blocking) | Detects renamed gadget |

### How the Port Check Works

```swift
// Non-blocking connect to Frida's default port.
// EINPROGRESS → something is listening (Frida server running)
// ECONNREFUSED → nothing listening (safe)
// The socket is closed immediately regardless of result.
```

### Frequency of Checks

Don't check only at launch — Frida can be injected into a running process.
For sensitive operations (payments, biometric auth), re-check inline:

```swift
func processPurchase() async {
    #if !DEBUG
    guard !ReverseEngineeringDetector.shared.isUnderAttack else {
        throw PaymentError.securityCheckFailed
    }
    #endif
    // proceed with payment
}
```
