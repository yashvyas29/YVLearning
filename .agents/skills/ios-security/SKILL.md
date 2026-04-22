---
name: ios-security
description: Implement, review, or audit iOS security mechanisms in YVLearning — including jailbreak/debug/RE detection, SSL pinning, string obfuscation, and binary integrity. Use when adding any manager from YVLearning/Common/Security/, designing a security posture, or reviewing security code for correctness.
license: MIT
metadata:
  author: Yash Vyas
  version: "1.0"
---

Implement and review iOS runtime security mechanisms. Apply defence-in-depth: no single check is unbypassable — the goal is raising the cost for an attacker, not achieving perfect security.

## Review / Implementation Process

1. Identify the threat category using `references/threat-model.md`.
2. For jailbreak, debug, and RE detection, load `references/runtime-protection.md`.
3. For SSL/TLS and network trust, load `references/network-security.md`.
4. For sensitive data, strings, and local storage security, load `references/data-protection.md`.
5. For distribution-channel and binary tampering checks, load `references/app-integrity.md`.
6. Load only the references relevant to the current task.

## Core Instructions

- Target iOS 17.0+ (Swift 6.2+, strict concurrency). All managers are `struct` or `final class`.
- Every security check must be **conditional on build configuration** (`#if !DEBUG`) unless the user explicitly requests runtime checks in debug builds. Security checks that produce false positives during development destroy trust in the whole system.
- Never `fatalError` on a failed check in release builds without user approval. Prefer graceful degradation (disable sensitive feature, log to analytics, show advisory).
- Layered detection is always better than a single check. Combine managers at the call site rather than making individual managers do too much.
- All managers follow the protocol + struct/class pattern already established in the project. Match it exactly.
- Security checks are side-effect-free reads. They must not modify app state, prompt the user, or make network requests.

## Output Format

When reviewing existing security code, organize findings by file. For each issue:

1. State the file and line(s).
2. Name the rule being violated.
3. Show a brief before/after code diff.

When implementing new security features, write the code directly and explain only non-obvious decisions.

## Quick Reference — Which Manager to Use

| Threat | Manager | Key API |
|--------|---------|---------|
| Jailbroken device | `JailbreakDetectionManager` | `.isJailbroken`, `.detectedIndicators` |
| Attached debugger | `DebugDetectionManager` | `.isDebugged`, `.isRunningOnSimulator` |
| Frida / Cycript injection | `ReverseEngineeringDetector` | `.isUnderAttack`, `.detectedIndicators` |
| MITM / rogue CA | `SSLPinningManager` | `.addPin(sha256Hash:for:)` as URLSession delegate |
| Plaintext secrets in binary | `ObfuscationManager` + `XORObfuscatedString` | `.encode(_:key:)`, `.decoded` |
| Sensitive data in memory | `SensitiveBuffer` | `.zeroize()` |
| Cracked / side-loaded IPA | `BinaryIntegrityManager` | `.isAppStoreInstall`, `.isRunningFromValidContainer` |
| Tampered resources | `BinaryIntegrityManager` | `.sha256(ofBundleResource:extension:)` |
| Device identity (server-side) | `DeviceCheckManager` | `.generateTokenBase64()` |
| App identity (server-side) | `AppAttestManager` | `.attest(keyId:challenge:)` |
| Sensitive credentials | `KeychainManager` | `.save(_:for:)`, `.load(for:)` |
| Crypto private keys | `SecureEnclaveManager` | `.loadOrCreateKey(tag:)`, `.sign(_:with:)` |

## References

- `references/threat-model.md` — iOS threat landscape, layered defence strategy, when each manager applies.
- `references/runtime-protection.md` — `JailbreakDetectionManager`, `DebugDetectionManager`, `ReverseEngineeringDetector` — patterns, integration, caveats.
- `references/network-security.md` — `SSLPinningManager` — pin management, obtaining hashes, URLSession integration, backup pins.
- `references/data-protection.md` — `ObfuscationManager`, `XORObfuscatedString`, `SensitiveBuffer`, `KeychainManager`, `SecureEnclaveManager` — patterns and anti-patterns.
- `references/app-integrity.md` — `BinaryIntegrityManager`, `AppAttestManager`, `DeviceCheckManager` — distribution validation, resource hashing, server-side device proofing.
