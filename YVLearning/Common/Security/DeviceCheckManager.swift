//
//  DeviceCheckManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import DeviceCheck

// MARK: - System Service Protocol

/// Thin abstraction over `DCDevice` so tests can inject a fake without hitting hardware.
protocol DeviceTokenService {
    var isSupported: Bool { get }
    func generateToken(completionHandler: @escaping @Sendable (Data?, Error?) -> Void)
}

extension DCDevice: DeviceTokenService {}

// MARK: - Manager Protocol

/// Abstraction over DeviceCheck operations. Conform a mock to this in tests.
protocol DeviceCheckManaging {
    var isSupported: Bool { get }
    func generateToken() async throws -> Data
    func generateTokenBase64() async throws -> String
}

// MARK: - Implementation

/// Demonstrates the DeviceCheck flow for associating persistent per-device
/// state with your developer account via Apple's servers.
///
/// DeviceCheck gives every device **two boolean bits** (`bit0`, `bit1`) per developer account.
/// These bits survive app uninstalls and device restores. They can only be read
/// or written by **your server** using Apple's DeviceCheck REST API — never from the device.
///
/// ## Bit State Convention (example)
///
/// | bit0  | bit1  | Meaning                  |
/// |-------|-------|--------------------------|
/// | false | false | New device, never seen   |
/// | true  | false | Free trial claimed       |
/// | false | true  | Account flagged          |
/// | true  | true  | Premium account enrolled |
///
/// ## Integration Flow
/// ```
/// Device                    Your Server              Apple API
/// ──────                    ───────────              ─────────
/// generateToken() ────────► POST /verify ──────────► validate token
///                                        ◄────────── bit0, bit1, lastModified
///                           write bits   ──────────► update bit0/bit1
/// ```
///
/// - Note: Tokens are ephemeral and expire quickly. Always generate a fresh token per request.
struct DeviceCheckManager: DeviceCheckManaging {
    static let shared = DeviceCheckManager()

    private let service: any DeviceTokenService

    init(service: any DeviceTokenService = DCDevice.current) {
        self.service = service
    }

    var isSupported: Bool { service.isSupported }

    // MARK: - Token Generation

    /// Generates an ephemeral device token to send to your server.
    ///
    /// Your server passes this token to Apple's DeviceCheck API at
    /// `https://api.devicecheck.apple.com/v1/validate_device_token` to read or update
    /// the device's two bits.
    func generateToken() async throws -> Data {
        guard isSupported else { throw DeviceCheckError.notSupported }
        return try await withCheckedThrowingContinuation { continuation in
            service.generateToken { token, error in
                if let error {
                    continuation.resume(throwing: DeviceCheckError.tokenGenerationFailed(error))
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: DeviceCheckError.tokenGenerationFailed(nil))
                }
            }
        }
    }

    /// Convenience: generates a token and returns it as a Base64 string,
    /// ready to include in an HTTP request body or header.
    func generateTokenBase64() async throws -> String {
        let token = try await generateToken()
        return token.base64EncodedString()
    }

    // MARK: - Errors

    enum DeviceCheckError: LocalizedError {
        case notSupported
        case tokenGenerationFailed(Error?)

        var errorDescription: String? {
            switch self {
            case .notSupported:
                return "DeviceCheck is not supported on this device or in the simulator."
            case .tokenGenerationFailed(let error):
                return "Token generation failed: \(error?.localizedDescription ?? "unexpected nil response from Apple.")"
            }
        }
    }
}
