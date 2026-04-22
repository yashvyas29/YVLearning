# App Integrity

Covers `BinaryIntegrityManager`, `AppAttestManager`, and `DeviceCheckManager`.

---

## The Three Layers of App Identity

```
Layer 1 — Client-side heuristics (BinaryIntegrityManager)
  Fast, no network, catches naive attacks.
  Can be bypassed by a sophisticated attacker with Frida.

Layer 2 — Apple-backed device proof (AppAttestManager)
  Requires Apple server round-trip. Cryptographically proves:
  - The request came from a genuine Apple device.
  - The specific app binary hasn't been tampered with.
  Cannot be faked — Apple's infrastructure validates it.

Layer 3 — Persistent device bits (DeviceCheckManager)
  Server stores 2 bits per device per developer account.
  Survives app uninstalls. Use for: free-trial tracking, fraud flags.
```

---

## BinaryIntegrityManager

**Location:** `YVLearning/Common/Security/BinaryIntegrityManager.swift`
**Protocol:** `BinaryIntegrityManaging`

### isAppStoreInstall

```swift
let integrity = BinaryIntegrityManager.shared

if !integrity.isAppStoreInstall {
    // Side-loaded, cracked, or running fresh in simulator
    // Log to analytics or degrade gracefully
}
```

| Scenario | `isAppStoreInstall` |
|----------|-------------------|
| App Store (after first launch) | `true` |
| TestFlight | `true` |
| Xcode direct install | `false` |
| Side-loaded (free developer cert) | `false` |
| Cracked IPA | `false` |
| Simulator | `false` |

**Caveat:** Brand-new App Store installs show `false` until the receipt is fetched
from Apple on first launch. Call `SKReceiptRefreshRequest` if you need to enforce this.

### isRunningFromValidContainer

```swift
if !integrity.isRunningFromValidContainer {
    // Binary has been extracted and re-executed from an abnormal path
}
```

Expected paths:
- Device: `/var/containers/Bundle/Application/<UUID>/YVLearning.app`
- Simulator: `.../CoreSimulator/Devices/<UUID>/data/Containers/Bundle/Application/...`

### hasEmbeddedProvisioningProfile

Use to enforce App Store-only distribution:

```swift
#if !DEBUG
if integrity.hasEmbeddedProvisioningProfile {
    // Dev, ad-hoc, or TestFlight — profile present
    // For production enforcement, consider degrading or alerting
}
#endif
```

### sha256(ofBundleResource:extension:)

Detect tampered resources at runtime. Record hashes at build time:

```swift
// 1. Record expected hash at build time (unit test or playground):
let expected = try BinaryIntegrityManager().sha256(
    ofBundleResource: "Config", extension: "plist"
)
// → "3a1b9c2f…"

// 2. Verify at runtime (e.g. app launch, before reading the config):
let current = try BinaryIntegrityManager().sha256(
    ofBundleResource: "Config", extension: "plist"
)
guard current == "3a1b9c2f…" else {
    // Config.plist was modified after distribution
    throw AppError.resourceTampered
}
```

---

## AppAttestManager

**Location:** `YVLearning/Common/Security/AppAttestManager.swift`
**Protocol:** `AppAttestManaging`
**Availability:** iOS 14+, requires `DCAppAttestService.shared.isSupported` — not available in Simulator.

### Two-Phase Flow

**Phase 1 — Key Attestation (once per device enrollment):**

```swift
guard AppAttestManager.shared.isSupported else { return }

// 1. Load or create the device's Secure Enclave-backed key
let keyId = try await AppAttestManager.shared.loadOrCreateKeyId()

// 2. Request a challenge nonce from your server
let challenge = try await myServer.fetchChallenge()

// 3. Attest the key — Apple verifies it and returns a receipt
let attestation = try await AppAttestManager.shared.attest(keyId: keyId, challenge: challenge)

// 4. Send attestation to your server for verification against Apple's API
try await myServer.verifyAttestation(keyId: keyId, attestation: attestation)
```

**Phase 2 — Request Assertion (every sensitive API call):**

```swift
// 1. Get fresh challenge from server
let challenge = try await myServer.fetchChallenge()

// 2. Serialize the request body
let requestData = try JSONEncoder().encode(myRequest)

// 3. Generate assertion — cryptographically binds the request + challenge
let assertion = try await AppAttestManager.shared.generateAssertion(
    keyId: keyId,
    requestData: requestData,
    challenge: challenge
)

// 4. Include assertion in API request headers
request.setValue(assertion.base64EncodedString(), forHTTPHeaderField: "X-App-Attest")
```

### Error Handling

```swift
do {
    let keyId = try await AppAttestManager.shared.loadOrCreateKeyId()
} catch AppAttestManager.AppAttestError.notSupported {
    // Simulator or older device — skip attestation
} catch AppAttestManager.AppAttestError.attestationFailed(let underlying) {
    // Network issue or Apple server error — retry with backoff
} catch {
    // Unexpected — log and fallback
}
```

---

## DeviceCheckManager

**Location:** `YVLearning/Common/Security/DeviceCheckManager.swift`
**Protocol:** `DeviceCheckManaging`

### What It Does

Generates an ephemeral token that your server sends to Apple to read/write
**two boolean bits** stored per device per developer account.
The bits survive app uninstalls and device restores.

### Common Bit Conventions

| bit0 | bit1 | Meaning |
|------|------|---------|
| `false` | `false` | New device, never seen |
| `true` | `false` | Free trial claimed |
| `false` | `true` | Device flagged |
| `true` | `true` | Premium enrolled |

### Usage

```swift
// 1. Generate a fresh token on the device
let tokenBase64 = try await DeviceCheckManager.shared.generateTokenBase64()

// 2. Send to your server — server calls Apple's DeviceCheck API:
// POST https://api.devicecheck.apple.com/v1/validate_device_token
// → Returns bit0, bit1, last_modification_time

// 3. Your server updates bits as needed via:
// POST https://api.devicecheck.apple.com/v1/update_two_bits
```

### Rules

- Tokens are **ephemeral** — generate a fresh one per request, never cache.
- All bit reads/writes happen **server-side** — the client cannot read its own bits.
- Not available in the Simulator — always check `isSupported`.

---

## Choosing Between AppAttest and DeviceCheck

| Requirement | Use |
|-------------|-----|
| Prove this request came from your unmodified app | `AppAttestManager` |
| Per-request integrity proof (replay protection) | `AppAttestManager` assertion |
| Track per-device state across uninstalls | `DeviceCheckManager` |
| Flag fraudulent devices server-side | `DeviceCheckManager` |
| iOS 14+ only is acceptable | `AppAttestManager` |
| iOS 11+ support needed | `DeviceCheckManager` |
