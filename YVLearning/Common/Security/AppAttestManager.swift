//
//  AppAttestManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import DeviceCheck
import CryptoKit

// MARK: - System Service Protocol

/// Thin abstraction over `DCAppAttestService` so tests can inject a fake without hitting hardware.
@available(iOS 14.0, *)
protocol AppAttestService {
    var isSupported: Bool { get }
    func generateKey(completionHandler: @escaping @Sendable (String?, Error?) -> Void)
    func attestKey(_ keyId: String, clientDataHash: Data, completionHandler: @escaping @Sendable (Data?, Error?) -> Void)
    func generateAssertion(_ keyId: String, clientDataHash: Data, completionHandler: @escaping @Sendable (Data?, Error?) -> Void)
}

@available(iOS 14.0, *)
extension DCAppAttestService: AppAttestService {}

// MARK: - Manager Protocol

/// Abstraction over App Attest operations. Conform a mock to this in tests.
@available(iOS 14.0, *)
protocol AppAttestManaging {
    var isSupported: Bool { get }
    func generateKey() async throws -> String
    func loadOrCreateKeyId() async throws -> String
    func deleteKeyId() throws
    func attest(keyId: String, challenge: Data) async throws -> Data
    func generateAssertion(keyId: String, requestData: Data, challenge: Data) async throws -> Data
}

// MARK: - Implementation

/// Demonstrates the App Attest flow for cryptographically proving that a request
/// originates from a genuine, unmodified copy of your app running on a real Apple device.
///
/// App Attest is stronger than DeviceCheck — it verifies the **app's identity**, not just
/// the device. It uses a Secure Enclave-backed key pair under the hood.
///
/// ## Two-Phase Flow
///
/// ### Phase 1 — Key Attestation (one-time per device enrollment)
/// ```
/// Device                              Your Server
/// ──────                              ───────────
/// loadOrCreateKeyId() ──────────────► store keyId for this user+device
///                     ◄────────────── send challenge (random nonce)
/// attest(keyId, challenge) ─────────► verify with Apple, store receipt
/// ```
///
/// ### Phase 2 — Request Assertion (every sensitive API call)
/// ```
/// Device                              Your Server
/// ──────                              ───────────
///                     ◄────────────── send fresh challenge
/// generateAssertion(keyId,
///   requestData, challenge) ─────────► verify assertion + counter
/// ```
///
/// - Important: App Attest is unavailable in the iOS Simulator and on jailbroken devices.
///   Always guard with ``isSupported`` before calling any method.
@available(iOS 14.0, *)
struct AppAttestManager: AppAttestManaging {
    static let shared = AppAttestManager()

    private let keyIdKeychainKey = "com.yvlearning.appattest.keyId"
    private let service: any AppAttestService
    private let keychain: any KeychainManaging

    init(
        service: any AppAttestService = DCAppAttestService.shared,
        keychain: any KeychainManaging = KeychainManager()
    ) {
        self.service = service
        self.keychain = keychain
    }

    var isSupported: Bool { service.isSupported }

    // MARK: - Key Lifecycle

    /// Generates a new App Attest key and persists its identifier in the Keychain.
    ///
    /// Call once per device enrollment. The key is SE-backed and never leaves the device.
    /// Re-use the stored key ID for all subsequent ``attest(keyId:challenge:)`` and
    /// ``generateAssertion(keyId:requestData:challenge:)`` calls.
    @discardableResult
    func generateKey() async throws -> String {
        guard isSupported else { throw AppAttestError.notSupported }
        let keyId: String = try await withCheckedThrowingContinuation { continuation in
            service.generateKey { keyId, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let keyId {
                    continuation.resume(returning: keyId)
                } else {
                    continuation.resume(throwing: AppAttestError.keyGenerationFailed)
                }
            }
        }
        try keychain.saveString(keyId, for: keyIdKeychainKey)
        return keyId
    }

    /// Returns the persisted key ID, generating and storing a new one if none exists.
    func loadOrCreateKeyId() async throws -> String {
        guard isSupported else { throw AppAttestError.notSupported }
        do {
            return try keychain.loadString(for: keyIdKeychainKey)
        } catch KeychainManager.KeychainError.itemNotFound {
            return try await generateKey()
        } catch {
            throw AppAttestError.keyIdLoadFailed(error)
        }
    }

    /// Removes the stored key ID from the Keychain.
    /// Use when re-enrolling the device (e.g. after a failed attestation).
    func deleteKeyId() throws {
        try keychain.delete(for: keyIdKeychainKey)
    }

    // MARK: - Phase 1: Attestation

    /// Attests the key against a server-provided challenge. **One-time per key.**
    ///
    /// Send the returned `Data` (a CBOR-encoded attestation object) to your server.
    /// Your server verifies it against Apple's App Attest service and stores the
    /// receipt for future assertion verification.
    ///
    /// - Parameters:
    ///   - keyId: The key ID from ``generateKey()`` or ``loadOrCreateKeyId()``.
    ///   - challenge: A random nonce fetched from your server (prevents replay attacks).
    /// - Returns: Attestation object to forward to your server.
    func attest(keyId: String, challenge: Data) async throws -> Data {
        guard isSupported else { throw AppAttestError.notSupported }
        let clientDataHash = Data(SHA256.hash(data: challenge))
        return try await withCheckedThrowingContinuation { continuation in
            service.attestKey(keyId, clientDataHash: clientDataHash) { attestation, error in
                if let error {
                    continuation.resume(throwing: AppAttestError.attestationFailed(error))
                } else if let attestation {
                    continuation.resume(returning: attestation)
                } else {
                    continuation.resume(throwing: AppAttestError.attestationFailed(nil))
                }
            }
        }
    }

    // MARK: - Phase 2: Assertion

    /// Generates a per-request assertion proving this request came from the attested app.
    ///
    /// Call before each sensitive API request. Your server verifies the assertion and
    /// checks that the internal counter only ever increases (replay protection).
    ///
    /// The `clientDataHash` is computed as `SHA256(requestData + challenge)` so the
    /// assertion cryptographically binds both the payload and the server nonce.
    ///
    /// - Parameters:
    ///   - keyId: The previously attested key ID.
    ///   - requestData: The serialised request body (e.g. `JSONEncoder().encode(payload)`).
    ///   - challenge: A fresh single-use nonce from your server.
    /// - Returns: Assertion object to include as a header or body field in your API request.
    func generateAssertion(keyId: String, requestData: Data, challenge: Data) async throws -> Data {
        guard isSupported else { throw AppAttestError.notSupported }
        var combined = requestData
        combined.append(challenge)
        let clientDataHash = Data(SHA256.hash(data: combined))
        return try await withCheckedThrowingContinuation { continuation in
            service.generateAssertion(keyId, clientDataHash: clientDataHash) { assertion, error in
                if let error {
                    continuation.resume(throwing: AppAttestError.assertionFailed(error))
                } else if let assertion {
                    continuation.resume(returning: assertion)
                } else {
                    continuation.resume(throwing: AppAttestError.assertionFailed(nil))
                }
            }
        }
    }

    // MARK: - Errors

    enum AppAttestError: LocalizedError {
        case notSupported
        case keyGenerationFailed
        case keyIdLoadFailed(Error)
        case attestationFailed(Error?)
        case assertionFailed(Error?)

        var errorDescription: String? {
            switch self {
            case .notSupported:
                return "App Attest is not supported on this device or in the simulator."
            case .keyGenerationFailed:
                return "Key generation returned neither a key ID nor an error."
            case .keyIdLoadFailed(let error):
                return "Failed to load key ID from Keychain: \(error.localizedDescription)"
            case .attestationFailed(let error):
                return "Key attestation failed: \(error?.localizedDescription ?? "unexpected nil response.")"
            case .assertionFailed(let error):
                return "Assertion generation failed: \(error?.localizedDescription ?? "unexpected nil response.")"
            }
        }
    }
}
