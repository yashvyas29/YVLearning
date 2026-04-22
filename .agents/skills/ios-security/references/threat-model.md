# iOS Threat Model

## Threat Landscape

iOS apps face attacks from two directions: **device-level compromise** (jailbreak) and **binary-level tampering** (IPA analysis, re-signing, hooking).

```
Attack Surface
│
├── Device Level
│   ├── Jailbroken device (sandbox removed, DYLD injection possible)
│   └── Simulator (no hardware protections)
│
├── Runtime Level
│   ├── Debugger attached (memory inspection, breakpoints)
│   ├── Frida / Cycript (JavaScript runtime hooks, method swizzling)
│   └── MobileSubstrate / Substitute (persistent hooks via dylib injection)
│
├── Network Level
│   ├── MITM via rogue CA (Charles, mitmproxy, Proxyman)
│   └── Certificate spoofing (fake cert from compromised/rogue CA)
│
├── Binary Level
│   ├── IPA extraction + static analysis (strings, Hopper, IDA Pro, class-dump)
│   ├── Re-packaging with malicious dylib, re-signing, side-loading
│   └── Resource tampering (swapped plists, modified assets)
│
└── Data Level
    ├── Keychain extraction on jailbroken device
    ├── Sensitive string extraction from binary
    └── Memory scraping (sensitive data lives too long in memory)
```

## Defence Layers — Which Manager Addresses Which Threat

| Threat | Primary Defence | Secondary Defence |
|--------|----------------|------------------|
| Jailbroken device | `JailbreakDetectionManager` | `AppAttestManager` (server-side) |
| Debugger attached | `DebugDetectionManager` | `JailbreakDetectionManager` |
| Frida / Cycript hooks | `ReverseEngineeringDetector` | `JailbreakDetectionManager` |
| MITM / rogue CA | `SSLPinningManager` | `AppAttestManager` |
| Plaintext secrets in binary | `XORObfuscatedString` | Code signing |
| Sensitive data in memory | `SensitiveBuffer` | `SecureEnclaveManager` |
| Cracked / side-loaded IPA | `BinaryIntegrityManager` | `AppAttestManager` |
| Tampered resources | `BinaryIntegrityManager.sha256` | Code signing |
| Persistent device flags | `DeviceCheckManager` (server-side) | — |
| App identity proof | `AppAttestManager` (server-side) | — |
| Credential storage | `KeychainManager` | `SecureEnclaveManager` |
| Crypto signing keys | `SecureEnclaveManager` | — |

## The Defence-in-Depth Principle

No individual check is unbypassable. A jailbreak detection bypass takes minutes with Frida. The goal is **layered cost elevation**:

1. A casual attacker (script-kiddie) is stopped by OS-level enforcement.
2. A motivated attacker bypasses jailbreak detection — but SSL pinning still blocks MITM.
3. An advanced attacker bypasses SSL pinning too — but App Attest proves device identity server-side.
4. Server-side validation (DeviceCheck, App Attest) is the hardest layer to bypass because it involves Apple's infrastructure.

## Recommended Security Posture

### Minimum (all production apps)
- `SSLPinningManager` — protects every network request
- `KeychainManager` — never store credentials in UserDefaults/plist

### Standard (apps with authentication or payments)
- Above, plus:
- `JailbreakDetectionManager` + `DebugDetectionManager` — gate sensitive flows
- `XORObfuscatedString` — for any embedded API keys/tokens

### Hardened (financial, healthcare, enterprise)
- Above, plus:
- `ReverseEngineeringDetector` — detect active instrumentation
- `BinaryIntegrityManager` — validate distribution channel
- `AppAttestManager` — server-side cryptographic app identity proof
- `SecureEnclaveManager` — hardware-backed key storage for signing

## What NOT to Do

| Anti-pattern | Risk |
|-------------|------|
| `fatalError()` on any security check in production | App crashes → 1-star reviews, App Store rejection |
| Single check gates everything | One bypass compromises the entire system |
| Checks only at launch | Frida can be injected after the app starts |
| Logging security check results | Reveals your detection logic to an attacker |
| Storing pin hashes or expected hashes in UserDefaults | Attacker can modify them |
