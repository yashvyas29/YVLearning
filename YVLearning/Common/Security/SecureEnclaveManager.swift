//
//  SecureEnclaveManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import CryptoKit
import Foundation

// MARK: - Protocol

/// Abstraction over Secure Enclave key operations. Conform a mock to this in tests.
protocol SecureEnclaveManaging {
    var isAvailable: Bool { get }
    @discardableResult
    func generateAndStoreKey(tag: String) throws -> SecureEnclave.P256.Signing.PrivateKey
    func loadOrCreateKey(tag: String) throws -> SecureEnclave.P256.Signing.PrivateKey
    func sign(_ data: Data, with privateKey: SecureEnclave.P256.Signing.PrivateKey) throws
        -> P256.Signing.ECDSASignature
    func verify(
        _ signature: P256.Signing.ECDSASignature, for data: Data,
        using publicKey: P256.Signing.PublicKey
    ) -> Bool
    func deleteKey(tag: String) throws
}

// MARK: - Implementation

/// Demonstrates Secure Enclave key generation, signing, and verification using CryptoKit.
///
/// Private keys are generated inside the Secure Enclave and never leave it.
/// Their opaque `dataRepresentation` (a wrapped reference, not the raw key) is
/// persisted in the Keychain so the key can be reloaded across app launches.
///
/// Biometric protection can be added by supplying a `SecAccessControl` during key creation:
/// ```swift
/// let access = SecAccessControlCreateWithFlags(
///     nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, [.privateKeyUsage, .biometryAny], nil
/// )!
/// let key = try SecureEnclave.P256.Signing.PrivateKey(accessControl: access)
/// ```
struct SecureEnclaveManager: SecureEnclaveManaging {
    static let shared = SecureEnclaveManager()

    private let keychain: any KeychainManaging

    init(keychain: any KeychainManaging = KeychainManager()) {
        self.keychain = keychain
    }

    /// Returns `true` when the current device has a Secure Enclave.
    var isAvailable: Bool { SecureEnclave.isAvailable }

    // MARK: - Key Lifecycle

    /// Generates a new P-256 signing key inside the Secure Enclave and stores its
    /// wrapped representation in the Keychain under `tag`.
    @discardableResult
    func generateAndStoreKey(tag: String) throws -> SecureEnclave.P256.Signing.PrivateKey {
        guard isAvailable else { throw SecureEnclaveError.notAvailable }
        let key = try SecureEnclave.P256.Signing.PrivateKey()
        try keychain.save(key.dataRepresentation, for: tag)
        return key
    }

    /// Loads an existing Secure Enclave key from the Keychain.
    /// If no key exists for `tag`, a new one is generated and stored automatically.
    func loadOrCreateKey(tag: String) throws -> SecureEnclave.P256.Signing.PrivateKey {
        guard isAvailable else { throw SecureEnclaveError.notAvailable }
        do {
            let data = try keychain.load(for: tag)
            return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
        } catch KeychainManager.KeychainError.itemNotFound {
            return try generateAndStoreKey(tag: tag)
        } catch {
            throw SecureEnclaveError.keyLoadFailed(error)
        }
    }

    /// Removes the wrapped key reference from the Keychain.
    /// The underlying Secure Enclave key material is destroyed automatically.
    func deleteKey(tag: String) throws {
        try keychain.delete(for: tag)
    }

    // MARK: - Signing & Verification

    /// Signs `data` using the given Secure Enclave private key.
    func sign(_ data: Data, with privateKey: SecureEnclave.P256.Signing.PrivateKey) throws
        -> P256.Signing.ECDSASignature
    {
        do {
            return try privateKey.signature(for: data)
        } catch {
            throw SecureEnclaveError.signingFailed(error)
        }
    }

    /// Verifies that `signature` was produced over `data` by the holder of the corresponding private key.
    func verify(
        _ signature: P256.Signing.ECDSASignature,
        for data: Data,
        using publicKey: P256.Signing.PublicKey
    ) -> Bool {
        publicKey.isValidSignature(signature, for: data)
    }

    // MARK: - Errors

    enum SecureEnclaveError: LocalizedError {
        case notAvailable
        case keyLoadFailed(Error)
        case signingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Secure Enclave is not available on this device or simulator."
            case .keyLoadFailed(let error):
                return "Failed to load Secure Enclave key: \(error.localizedDescription)"
            case .signingFailed(let error):
                return "Signing operation failed: \(error.localizedDescription)"
            }
        }
    }
}
