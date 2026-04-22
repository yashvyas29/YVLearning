# Network Security — SSL/TLS Pinning

Covers `SSLPinningManager`.

**Location:** `YVLearning/Common/Security/SSLPinningManager.swift`
**Protocol:** `SSLPinningManaging` (extends `URLSessionDelegate`)
**Type:** `final class SSLPinningManager: NSObject, @unchecked Sendable`

---

## How Public Key Pinning Works

```
App launch                    API call
    │                             │
    ▼                             ▼
addPin(hash, host)        URLSession → challenge
    │                             │
    ▼                             ▼
stored in                validate(serverTrust, host)
pinnedKeyHashes               │
(NSLock-protected)            ├── extract leaf cert public key
                              ├── SHA-256 hash key bytes
                              └── compare against stored pins
                                   ├── match → useCredential ✓
                                   └── no match → cancelAuthenticationChallenge ✗
```

---

## Obtaining a Pin Hash

Run this command against the live server:

```bash
openssl s_client -connect api.example.com:443 -servername api.example.com \
  < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | base64
```

Or against a local `.cer` file:

```bash
openssl x509 -in certificate.cer -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | base64
```

---

## Setup Pattern

Configure pins **once at app startup** before any network request fires:

```swift
// In App.init or AppDelegate.application(_:didFinishLaunchingWithOptions:)
func configurePinning() {
    let pinning = SSLPinningManager.shared

    // Always register at least two pins: primary + backup key
    pinning.addPin(sha256Hash: "abc123+primaryHash=", for: "api.example.com")
    pinning.addPin(sha256Hash: "xyz789+backupHash==", for: "api.example.com")

    // Intermediate CA pin (optional — survives leaf cert rotation)
    pinning.addPin(sha256Hash: "def456+intermediateCA=", for: "api.example.com")
}

// Create the URLSession with the pinning manager as delegate
let pinnedSession = URLSession(
    configuration: .default,
    delegate: SSLPinningManager.shared,
    delegateQueue: nil
)
```

---

## Key API Reference

```swift
// Add a pin for a host
SSLPinningManager.shared.addPin(sha256Hash: "base64hash=", for: "host.example.com")

// Remove all pins for a host (reverts to default OS validation)
SSLPinningManager.shared.removePins(for: "host.example.com")

// Manual validation (for custom delegate chains)
let trusted = SSLPinningManager.shared.validate(
    serverTrust: serverTrust,
    host: "host.example.com"
)
```

---

## Hosts With No Pins

If no pins are registered for a host, `validate(serverTrust:host:)` returns `true`
and the delegate calls `completionHandler(.performDefaultHandling, nil)`.

This means you can adopt pinning incrementally — only pin hosts that matter
(API backend, auth server) without breaking image CDNs, analytics, etc.

---

## Backup Pins — Critical

**Always register at least two pins.** If you pin to a single certificate and the
private key is lost (HSM failure, security incident), every user on that app version
loses all API connectivity until you ship an emergency update.

Best practice:
1. **Primary pin** — current leaf certificate public key
2. **Backup pin** — next key pair (already generated, not yet in use)
3. **CA pin** (optional) — intermediate CA; survives leaf cert rotation automatically

---

## Anti-Patterns

| ❌ | ✅ |
|---|---|
| `completionHandler(.useCredential, nil)` — credential-less accept | `completionHandler(.useCredential, URLCredential(trust: serverTrust))` |
| Single pin with no backup | Always 2+ pins |
| Hardcoding pins in UserDefaults | Hardcode in source — UserDefaults is attacker-writable |
| Pinning in debug builds | Wrap pin setup with `#if !DEBUG` or skip validation in dev |
| Reusing URLSession without the pinning delegate | Always create sessions via `URLSession(configuration:delegate:delegateQueue:)` |

---

## Testing SSL Pinning

In tests, inject a mock instead of the shared instance:

```swift
final class MockSSLPinningManager: NSObject, SSLPinningManaging {
    var shouldAccept = true

    func addPin(sha256Hash: String, for host: String) {}
    func removePins(for host: String) {}

    func validate(serverTrust: SecTrust, host: String) -> Bool { shouldAccept }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(shouldAccept ? .useCredential : .cancelAuthenticationChallenge,
                          shouldAccept ? URLCredential(trust: challenge.protectionSpace.serverTrust!) : nil)
    }
}
```
