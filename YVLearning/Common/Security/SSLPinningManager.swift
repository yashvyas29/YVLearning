//
//  SSLPinningManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import CryptoKit
import Foundation
import Security

// MARK: - Protocol

/// Abstraction over SSL/TLS pinning. Use in tests to inject a pass-through mock.
protocol SSLPinningManaging: URLSessionDelegate {
    func addPin(sha256Hash: String, for host: String)
    func removePins(for host: String)
    func validate(serverTrust: SecTrust, host: String) -> Bool
}

// MARK: - Implementation

/// Performs public key pinning for URLSession TLS connections.
///
/// Public key pinning binds one or more expected server public keys to a hostname.
/// Connections to a host whose certificate chain does not contain a pinned key are
/// rejected, preventing MITM attacks even when a rogue CA issues a trusted certificate.
///
/// ## Why Public Key vs. Certificate Pinning?
///
/// Pinning the **public key** (not the full certificate) means you can renew/rotate
/// certificates without updating the app, as long as the same key pair is reused.
///
/// ## Obtaining a Pin Hash
///
/// Run this command to extract the Base64-encoded SHA-256 hash of the server's public key:
///
/// ```bash
/// openssl s_client -connect api.example.com:443 -servername api.example.com \
///   < /dev/null 2>/dev/null \
///   | openssl x509 -pubkey -noout \
///   | openssl pkey -pubin -outform DER \
///   | openssl dgst -sha256 -binary \
///   | base64
/// ```
///
/// ## Integration
///
/// Configure pins once at app startup (e.g. `App.init` or `AppDelegate`):
///
/// ```swift
/// SSLPinningManager.shared.addPin(sha256Hash: "<base64-hash>", for: "api.example.com")
/// SSLPinningManager.shared.addPin(sha256Hash: "<backup-hash>", for: "api.example.com")
///
/// let session = URLSession(
///     configuration: .default,
///     delegate: SSLPinningManager.shared,
///     delegateQueue: nil
/// )
/// ```
///
/// - Note: Hosts with no registered pins fall through to the default OS TLS validation,
///   so you can adopt pinning incrementally.
/// - Warning: Always register a **backup pin** (from the next key pair). Losing the
///   private key while using a single pin will lock all app users out of the API.
final class SSLPinningManager: NSObject, SSLPinningManaging, @unchecked Sendable {
    static let shared = SSLPinningManager()

    private var pinnedKeyHashes: [String: Set<String>] = [:]
    private let lock = NSLock()

    override init() { super.init() }

    // MARK: - Pin Management

    /// Registers a pinned public key hash for the given host.
    ///
    /// - Parameters:
    ///   - sha256Hash: Base64-encoded SHA-256 hash of the DER-encoded public key bytes.
    ///   - host: Exact hostname to pin (e.g. `"api.example.com"`).
    func addPin(sha256Hash: String, for host: String) {
        lock.lock()
        defer { lock.unlock() }
        pinnedKeyHashes[host, default: []].insert(sha256Hash)
    }

    /// Removes all registered pins for the given host, reverting to default OS validation.
    func removePins(for host: String) {
        lock.lock()
        defer { lock.unlock() }
        pinnedKeyHashes.removeValue(forKey: host)
    }

    // MARK: - Validation

    /// Validates the server's leaf-certificate public key against the pins registered for `host`.
    ///
    /// - Returns: `true` when the key matches a pin, or when no pins are registered for the host.
    ///   Returns `false` if the public key cannot be extracted or does not match any registered pin.
    func validate(serverTrust: SecTrust, host: String) -> Bool {
        lock.lock()
        let pins = pinnedKeyHashes[host]
        lock.unlock()

        guard let pins, !pins.isEmpty else { return true }

        guard
            let leafCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let publicKey = SecCertificateCopyKey(leafCertificate)
        else {
            return false
        }

        var exportError: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &exportError) else {
            return false
        }

        let keyHash = Data(SHA256.hash(data: keyData as Data)).base64EncodedString()
        return pins.contains(keyHash)
    }

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler:
            @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host
        if validate(serverTrust: serverTrust, host: host) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
