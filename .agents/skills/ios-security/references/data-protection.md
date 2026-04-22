# Data Protection

Covers `ObfuscationManager`, `XORObfuscatedString`, `SensitiveBuffer`,
`KeychainManager`, and `SecureEnclaveManager`.

---

## Sensitive Data Decision Tree

```
Where does the sensitive value come from?
│
├── Hardcoded in source (API key, salt, endpoint)
│   └── → XORObfuscatedString
│
├── User-entered or received from network (password, token, private key)
│   ├── Needs to persist across app launches → KeychainManager
│   ├── Needs hardware-backed crypto operations → SecureEnclaveManager
│   └── Temporary (only needed for one operation) → SensitiveBuffer
│
└── Computed at runtime (derived key, decrypted payload)
    └── → SensitiveBuffer (zero after use)
```

---

## XORObfuscatedString

**Location:** `YVLearning/Common/Security/ObfuscationManager.swift`

Prevents plaintext secrets from appearing in the binary where `strings` or Hopper can extract them.

### Workflow

**Step 1 — Encode at dev time** (in a playground, test, or scratch file — never ship this):
```swift
let encoded = ObfuscationManager.encode("sk-live-abc123", key: 0x4F)
print(encoded)
// → [0x3C, 0x27, 0x23, 0x2B, 0x23, 0x7B, 0x23, 0x63, 0x23, 0x6B, ...]
```

**Step 2 — Embed the byte array** (the plaintext is now gone from source):
```swift
private static let apiKey = XORObfuscatedString(
    encoded: [0x3C, 0x27, 0x23, 0x2B, 0x23, 0x7B, 0x23, 0x63, 0x23, 0x6B],
    key: 0x4F
)
```

**Step 3 — Decode only at the point of use**:
```swift
func makeAuthenticatedRequest() async throws -> Data {
    let key = Self.apiKey.decoded  // String is created here, in memory
    var request = URLRequest(url: url)
    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
    return try await URLSession.shared.data(for: request).0
    // 'key' goes out of scope → ARC frees the String allocation
}
```

### Rules

- Use a **different `key` per secret** — don't use `0x42` for everything.
- Never `print`, `log`, or store `decoded` anywhere persistent.
- Combine with `JailbreakDetectionManager` — on jailbroken devices, memory can be scraped.

### Verification Helper

```swift
// Smoke-test during development — confirms the byte array round-trips correctly:
assert(ObfuscationManager.verify(
    encoded: [0x3C, 0x27, 0x23],
    key: 0x4F,
    expectedPlaintext: "sk-"
))
```

---

## SensitiveBuffer

**Location:** `YVLearning/Common/Security/ObfuscationManager.swift`

Wraps a `Data` value and overwrites it with zeros when done.

```swift
// Receive private key material from network or crypto operation
let buffer = SensitiveBuffer(privateKeyData)

// Use it
let signature = try signData(using: buffer.data)

// Explicitly zero — don't rely solely on deinit
buffer.zeroize()
```

### Limitation

Swift's optimizer may treat the zero-write as a dead store and elide it.
`SensitiveBuffer` uses an indexed loop through `withUnsafeMutableBufferPointer`
to reduce (not eliminate) this risk. For cryptographic-grade zeroing in production,
call into a C function using `memset_s`:

```c
// In a bridging header:
static inline void secure_zero(void *ptr, size_t n) {
    memset_s(ptr, n, 0, n);  // C11 — guaranteed not optimized away
}
```

```swift
// In Swift:
buffer.data.withUnsafeBytes { ptr in
    if let base = ptr.baseAddress {
        secure_zero(UnsafeMutableRawPointer(mutating: base), ptr.count)
    }
}
```

---

## KeychainManager

**Location:** `YVLearning/Common/Security/KeychainManager.swift`
**Protocol:** `KeychainManaging`

Use for any value that must persist across app launches and survive app updates.

```swift
let keychain = KeychainManager.shared

// Store
try keychain.saveString(authToken, for: "com.yvlearning.authToken")

// Load
let token = try keychain.loadString(for: "com.yvlearning.authToken")

// Delete on sign-out
try keychain.delete(for: "com.yvlearning.authToken")
```

### Access Control

The default access level is `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` — the item
is accessible only when the device is unlocked and cannot be migrated to another device
via backup. This is the correct default for credentials and tokens.

For biometric-protected items, add an access control when saving:
```swift
// Build access control (requires SecItemAdd directly, not through KeychainManager's save)
let access = SecAccessControlCreateWithFlags(
    nil,
    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    [.biometryAny],
    nil
)
```

### Rules

| ❌ Never | ✅ Instead |
|---------|-----------|
| `UserDefaults` for tokens/passwords | `KeychainManager` |
| `FileManager` / plist for credentials | `KeychainManager` |
| Force-try Keychain calls | Handle `KeychainError` cases |
| Same key string for different items | Namespaced reverse-DNS key: `"com.yvlearning.feature.item"` |

---

## SecureEnclaveManager

**Location:** `YVLearning/Common/Security/SecureEnclaveManager.swift`
**Protocol:** `SecureEnclaveManaging`

Use when you need **hardware-backed cryptographic key storage**. The private key never
leaves the Secure Enclave — it cannot be extracted even on a jailbroken device.

```swift
let se = SecureEnclaveManager.shared
guard se.isAvailable else { /* fallback */ return }

// Create or load a P-256 signing key
let privateKey = try se.loadOrCreateKey(tag: "com.yvlearning.signingKey")

// Sign a challenge (e.g. for server-side authentication)
let data = Data("challenge-nonce".utf8)
let signature = try se.sign(data, with: privateKey)

// Verify (typically done server-side using the public key)
let isValid = se.verify(signature, for: data, using: privateKey.publicKey)
```

### When to use SE vs Keychain

| Use `SecureEnclaveManager` | Use `KeychainManager` |
|--------------------------|----------------------|
| Private keys for signing | Tokens, passwords, API keys |
| Hardware-backed key proof | Items that need to leave the device (e.g. sync) |
| P-256 ECDSA operations | String/Data storage |
| Biometric-protected operations | Standard protected storage |
