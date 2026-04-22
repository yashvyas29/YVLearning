//
//  JailbreakDetectionManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation

// MARK: - Protocol

/// Abstraction over jailbreak detection. Conform a mock to this in tests.
protocol JailbreakDetecting {
    var isJailbroken: Bool { get }
    var detectedIndicators: [JailbreakDetectionManager.Indicator] { get }
}

// MARK: - Implementation

/// Detects common jailbreak indicators on the current device.
///
/// Jailbroken devices bypass the iOS sandbox, exposing apps to risks such as:
/// - Memory inspection and binary patching (Frida, Cycript, LLDB)
/// - Keychain data extraction by other apps
/// - SSL traffic interception via MITM proxies
/// - Code injection via MobileSubstrate / Substitute
///
/// ## Checks Performed
///
/// | Indicator | Detection Method |
/// |-----------|-----------------|
/// | `suspiciousFilePath` | Known jailbreak artifact paths (Cydia, apt, sshd, …) |
/// | `sandboxViolation` | Attempts to write a file outside the app's sandbox |
/// | `applicationsSymlink` | Whether `/Applications` has been replaced with a symlink |
/// | `dylibInjection` | `DYLD_INSERT_LIBRARIES` environment variable is set |
///
/// ### Optional: cydia:// URL Scheme Check
/// You can add an additional indicator using `UIApplication.shared.canOpenURL` with
/// `cydia://`. This requires `"cydia"` in `LSApplicationQueriesSchemes` (Info.plist)
/// and must be called on the main thread.
///
/// - Warning: No jailbreak detection is foolproof. Modern jailbreaks (Dopamine, palera1n)
///   actively hide their traces. A negative result means "no obvious indicators found",
///   not a guarantee the device is clean.
/// - Note: All checks pass cleanly on the iOS Simulator — no false positives in dev.
struct JailbreakDetectionManager: JailbreakDetecting {
    static let shared = JailbreakDetectionManager()

    init() {}

    // MARK: - Indicator

    enum Indicator: String, CaseIterable, Sendable {
        case suspiciousFilePath  = "Suspicious jailbreak file path detected"
        case sandboxViolation    = "App can write outside its sandbox"
        case applicationsSymlink = "/Applications is a symbolic link"
        case dylibInjection      = "DYLD_INSERT_LIBRARIES environment variable is set"
    }

    // MARK: - JailbreakDetecting

    /// Returns `true` if at least one jailbreak indicator was found.
    var isJailbroken: Bool { !detectedIndicators.isEmpty }

    /// Returns all indicators triggered during detection.
    var detectedIndicators: [Indicator] {
        var found: [Indicator] = []
        if hasSuspiciousFiles     { found.append(.suspiciousFilePath) }
        if hasSandboxViolation    { found.append(.sandboxViolation) }
        if hasApplicationsSymlink { found.append(.applicationsSymlink) }
        if hasDylibInjection      { found.append(.dylibInjection) }
        return found
    }

    // MARK: - Private Checks

    /// Checks for well-known jailbreak artifacts on the file system.
    private var hasSuspiciousFiles: Bool {
        let paths: [String] = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/DynamicLibraries",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/usr/bin/sshd",
            "/usr/sbin/sshd",
            "/usr/libexec/sftp-server",
            "/bin/bash",
            "/etc/apt",
            "/etc/ssh/sshd_config",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"
        ]
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    /// Attempts to write a file to a path outside the app's sandbox.
    /// Succeeds only on jailbroken devices where sandbox restrictions have been lifted.
    private var hasSandboxViolation: Bool {
        let path = "/private/jailbreak-probe-\(UUID().uuidString)"
        do {
            try "probe".write(toFile: path, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    /// On jailbroken devices, `/Applications` is often replaced with a symlink
    /// pointing to `/private/var/stash/…` to accommodate extra app storage.
    private var hasApplicationsSymlink: Bool {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: "/Applications")
            return attrs[.type] as? FileAttributeType == .typeSymbolicLink
        } catch {
            return false
        }
    }

    /// `DYLD_INSERT_LIBRARIES` is set when a library is being injected into the process —
    /// the mechanism used by MobileSubstrate, Substrate, and Frida to hook apps at runtime.
    private var hasDylibInjection: Bool {
        ProcessInfo.processInfo.environment["DYLD_INSERT_LIBRARIES"] != nil
    }
}
