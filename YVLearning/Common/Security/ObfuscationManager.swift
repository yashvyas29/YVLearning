//
//  ObfuscationManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation

// MARK: - XORObfuscatedString

/// A string whose bytes are XOR-encoded so the plaintext never appears in the binary.
///
/// Static analysis tools (`strings`, IDA Pro, Hopper, class-dump) can trivially extract
/// string literals from a compiled binary. `XORObfuscatedString` stores the secret as a
/// XOR-encoded byte array, so the plaintext only exists in memory **at the moment it is
/// needed**, and only for as long as the caller holds onto it.
///
/// ## How to Prepare Encoded Bytes
///
/// At development time, use `ObfuscationManager.encode(_:key:)` to get the byte array:
///
/// ```swift
/// // In a playground or test — never ship this line:
/// print(ObfuscationManager.encode("sk-live-abc123", key: 0x4F))
/// // → [0x3C, 0x27, 0x23, 0x2B, 0x2B, 0x23, 0x18, ...]
///
/// // Embed the output in your source:
/// static let apiKey = XORObfuscatedString(
///     encoded: [0x3C, 0x27, 0x23, 0x2B, 0x2B, 0x23, 0x18, ...],
///     key: 0x4F
/// )
///
/// // Decode only when needed:
/// let key = apiKey.decoded()
/// ```
///
/// ## Limitations
///
/// This is **runtime** obfuscation. The encoded byte array is still in the binary — a
/// determined analyst can reconstruct the secret by XOR-decoding the bytes. For stronger
/// protection, combine with:
/// - Code signing (`BinaryIntegrityManager`)
/// - Jailbreak detection (`JailbreakDetectionManager`)
/// - Anti-debugging (`DebugDetectionManager`)
/// - Swift macros or LLVM build-time plugins for compile-time string encryption
struct XORObfuscatedString: Sendable {
    private let bytes: [UInt8]
    private let key: UInt8

    /// Creates an obfuscated string from pre-encoded bytes and the XOR key.
    ///
    /// - Parameters:
    ///   - bytes: Byte array produced by `ObfuscationManager.encode(_:key:)`.
    ///   - key: The XOR key used during encoding.
    init(encoded bytes: [UInt8], key: UInt8) {
        self.bytes = bytes
        self.key = key
    }

    /// Decodes and returns the original string. Each call allocates a new `String`.
    ///
    /// Avoid storing the decoded value; let it go out of scope as soon as possible.
    var decoded: String {
        String(bytes: bytes.map { $0 ^ key }, encoding: .utf8) ?? ""
    }
}

// MARK: - SensitiveBuffer

/// Wraps a `Data` value and overwrites its memory content when cleared or deallocated.
///
/// Swift's garbage collector and optimizer make it difficult to guarantee a zeroed
/// buffer at the C level. `SensitiveBuffer` makes a best-effort overwrite using
/// a volatile-equivalent write loop, which modern compilers are less likely to
/// eliminate as dead code compared to plain `memset`.
///
/// For cryptographic-strength zeroing in production, use `SecureZeroMemory`
/// (Windows) or `memset_s` (C11) via a thin C shim.
///
/// ```swift
/// let buffer = SensitiveBuffer(privateKeyData)
/// // use buffer.data for operations
/// buffer.zeroize() // explicit clear; also called automatically on deinit
/// ```
final class SensitiveBuffer: @unchecked Sendable {
    private var storage: ContiguousArray<UInt8>

    init(_ data: Data) {
        storage = ContiguousArray(data)
    }

    /// The current buffer contents as `Data`.
    var data: Data { Data(storage) }

    /// Overwrites every byte with zero, then releases the allocation.
    ///
    /// - Note: Called automatically on `deinit`. Safe to call multiple times.
    func zeroize() {
        // Write through the buffer pointer to reduce the chance the
        // optimizer treats this as a dead store.
        storage.withUnsafeMutableBufferPointer { buffer in
            for index in buffer.indices { buffer[index] = 0 }
        }
        storage.removeAll(keepingCapacity: false)
    }

    deinit { zeroize() }
}

// MARK: - ObfuscationManager

/// Utility namespace for XOR encoding/decoding and sensitive-value helpers.
///
/// Use `encode(_:key:)` **at development time only** (in a playground or scratch file)
/// to generate encoded byte arrays to embed in your source code.
/// Never ship a call to `encode` that reveals the plaintext in a log or assertion.
enum ObfuscationManager {

    /// Encodes `string` using XOR with `key`, returning the byte array to embed in source.
    ///
    /// - Parameters:
    ///   - string: The plaintext string to obfuscate.
    ///   - key: A `UInt8` XOR key. Use a different key per secret.
    /// - Returns: `[UInt8]` literal suitable for pasting into `XORObfuscatedString(encoded:key:)`.
    static func encode(_ string: String, key: UInt8) -> [UInt8] {
        string.utf8.map { $0 ^ key }
    }

    /// Convenience round-trip: encodes then immediately decodes. Useful for smoke-testing
    /// a key/byte-array pair without shipping the plaintext.
    static func verify(encoded bytes: [UInt8], key: UInt8, expectedPlaintext: String) -> Bool {
        XORObfuscatedString(encoded: bytes, key: key).decoded == expectedPlaintext
    }
}
