//
//  BinaryIntegrityManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import CryptoKit

// MARK: - Protocol

/// Abstraction over binary and bundle integrity checks. Conform a mock to this in tests.
protocol BinaryIntegrityManaging {
    var isAppStoreInstall: Bool { get }
    var isRunningFromValidContainer: Bool { get }
    var hasEmbeddedProvisioningProfile: Bool { get }
    func sha256(ofBundleResource name: String, extension ext: String) throws -> String
}

// MARK: - Implementation

/// Verifies the app's distribution channel, container path, and resource integrity.
///
/// iOS enforces code signing at launch, so a modified binary cannot run on a
/// non-jailbroken device. However, attackers can:
///
/// - Repackage the IPA with a malicious dylib, re-sign with a free developer cert,
///   and side-load it onto a jailbroken device.
/// - Use Clutch or similar tools to decrypt the binary from memory, then re-distribute.
/// - Swap out app resources (images, localization files) that affect behaviour.
///
/// `BinaryIntegrityManager` provides checks that catch these scenarios at runtime.
///
/// ## Checks
///
/// | Check | What it detects |
/// |-------|----------------|
/// | `isAppStoreInstall` | Presence of an App Store receipt — absent on cracked / side-loaded builds |
/// | `isRunningFromValidContainer` | App is running from the expected iOS container path |
/// | `hasEmbeddedProvisioningProfile` | Profile present → dev/ad-hoc; absent → App Store |
/// | `sha256(ofBundleResource:extension:)` | Detect tampered/swapped bundle resources |
///
/// ## Usage
///
/// Combine with `JailbreakDetectionManager` and `AppAttestManager` for layered protection:
///
/// ```swift
/// #if !DEBUG
/// let integrity = BinaryIntegrityManager()
/// guard integrity.isRunningFromValidContainer else {
///     // Abnormal execution path — terminate or degrade gracefully
///     fatalError("Integrity check failed.")
/// }
/// #endif
/// ```
struct BinaryIntegrityManager: BinaryIntegrityManaging {
    static let shared = BinaryIntegrityManager()

    init() {}

    // MARK: - Distribution Channel

    /// Returns `true` if an App Store receipt is present.
    ///
    /// App Store and TestFlight builds include a receipt at
    /// `Bundle.main.appStoreReceiptURL`. The file is absent when:
    /// - The app was side-loaded without going through App Store Connect.
    /// - The IPA was cracked and re-distributed outside the App Store.
    ///
    /// - Note: The simulator and fresh App Store installs may show `false` until the
    ///   first receipt refresh. Use this as one signal among several.
    var isAppStoreInstall: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return FileManager.default.fileExists(atPath: receiptURL.path)
    }

    /// Returns `true` if the app is running from the expected system container.
    ///
    /// A legitimate iOS installation runs from:
    /// - `/var/containers/Bundle/Application/<UUID>/` on device
    /// - A CoreSimulator path on the iOS Simulator
    ///
    /// If the binary has been extracted and re-executed from an unusual path
    /// (e.g. `/tmp`, `/var/mobile/Documents`), this check returns `false`.
    var isRunningFromValidContainer: Bool {
        let path = Bundle.main.bundlePath
        return path.contains("/var/containers/Bundle/Application/") ||
               path.contains("/CoreSimulator/")
    }

    // MARK: - Distribution Type

    /// Returns `true` when an `embedded.mobileprovision` file is present in the bundle.
    ///
    /// | Scenario | Profile present |
    /// |----------|----------------|
    /// | App Store release | No (Apple strips it) |
    /// | TestFlight | Yes |
    /// | Ad-hoc / Enterprise | Yes |
    /// | Development (Xcode) | Yes |
    ///
    /// Use this to enforce App Store-only distribution in sensitive builds.
    var hasEmbeddedProvisioningProfile: Bool {
        Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision") != nil
    }

    // MARK: - Resource Integrity

    /// Computes the lowercase hex SHA-256 digest of a bundle resource.
    ///
    /// Record the expected hash at build time and verify at runtime to detect
    /// resources that have been swapped or modified after distribution.
    ///
    /// ```swift
    /// // At build time (playground / unit test), record the hash:
    /// let hash = try BinaryIntegrityManager().sha256(ofBundleResource: "Config", extension: "plist")
    /// // → "a3f1c9…"
    ///
    /// // At runtime, verify:
    /// let current = try BinaryIntegrityManager().sha256(ofBundleResource: "Config", extension: "plist")
    /// guard current == "a3f1c9…" else { /* tampered resource */ }
    /// ```
    ///
    /// - Parameters:
    ///   - name: Resource file name without extension.
    ///   - ext: File extension (e.g. `"plist"`, `"json"`).
    /// - Returns: Lowercase hex-encoded SHA-256 digest string.
    /// - Throws: `IntegrityError.resourceNotFound` if the resource cannot be located.
    func sha256(ofBundleResource name: String, extension ext: String) throws -> String {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: ext),
            let data = try? Data(contentsOf: url, options: .mappedIfSafe)
        else {
            throw IntegrityError.resourceNotFound("\(name).\(ext)")
        }
        return Data(SHA256.hash(data: data))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    // MARK: - Errors

    enum IntegrityError: LocalizedError {
        case resourceNotFound(String)

        var errorDescription: String? {
            switch self {
            case .resourceNotFound(let resource):
                return "Bundle resource '\(resource)' not found — cannot compute integrity hash."
            }
        }
    }
}
