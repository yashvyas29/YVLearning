//
//  KeychainManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import Security

// MARK: - Protocol

/// Abstraction over Keychain operations. Conform a mock to this in tests.
protocol KeychainManaging {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data
    func update(_ data: Data, for key: String) throws
    func delete(for key: String) throws
    func saveString(_ string: String, for key: String) throws
    func loadString(for key: String) throws -> String
}

// MARK: - Implementation

/// Provides type-safe Keychain read/write/delete operations for generic password items.
struct KeychainManager: KeychainManaging {
    static let shared = KeychainManager()

    // MARK: - Data Operations

    func save(_ data: Data, for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            try update(data, for: key)
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }

    func load(for key: String) throws -> Data {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw KeychainError.loadFailed(status) }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.loadFailed(status)
        }
    }

    func update(_ data: Data, for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let attributes: [CFString: Any] = [kSecValueData: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.updateFailed(status) }
    }

    func delete(for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - String Convenience

    func saveString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else { throw KeychainError.encodingFailed }
        try save(data, for: key)
    }

    func loadString(for key: String) throws -> String {
        let data = try load(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        return string
    }

    // MARK: - Errors

    enum KeychainError: LocalizedError {
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case updateFailed(OSStatus)
        case deleteFailed(OSStatus)
        case itemNotFound
        case encodingFailed
        case decodingFailed

        var errorDescription: String? {
            switch self {
            case .saveFailed(let status): return "Keychain save failed (OSStatus \(status))."
            case .loadFailed(let status): return "Keychain load failed (OSStatus \(status))."
            case .updateFailed(let status): return "Keychain update failed (OSStatus \(status))."
            case .deleteFailed(let status): return "Keychain delete failed (OSStatus \(status))."
            case .itemNotFound: return "Item not found in Keychain."
            case .encodingFailed: return "Failed to encode string to Data."
            case .decodingFailed: return "Failed to decode Data to String."
            }
        }
    }
}
