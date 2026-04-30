//
//  ReverseEngineeringDetector.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import Darwin
import MachO

// MARK: - Protocol

/// Abstraction over reverse-engineering detection. Conform a mock to this in tests.
protocol ReverseEngineeringDetecting {
    var isUnderAttack: Bool { get }
    var detectedIndicators: [ReverseEngineeringDetector.Indicator] { get }
}

// MARK: - Implementation

/// Detects active reverse-engineering and runtime-manipulation tools.
///
/// While `JailbreakDetectionManager` checks the device state and `DebugDetectionManager`
/// checks for attached debuggers, this manager specifically looks for tools that inject
/// into the running process to intercept and modify behavior at runtime.
///
/// ## Tools Detected
///
/// | Tool | Detection Method |
/// |------|-----------------|
/// | Frida | Dylib scan (`frida-agent`, `FridaGadget`) + port 27042 probe |
/// | Cycript | Dylib scan (`cynject`, `cycript`) |
/// | MobileSubstrate | Dylib scan (`MobileSubstrate`, `substrate`) |
/// | Substitute | Dylib scan (`libsubstitute`) |
/// | libhooker | Dylib scan (`libhooker`) |
/// | SSLKillSwitch | Dylib scan (`SSLKillSwitch`) — active SSL bypass |
/// | Reveal | Dylib scan (`RevealServer`) — UI inspection |
///
/// ## Frida Port Detection
///
/// Frida's default port is 27042. Attempting a non-blocking TCP connect to
/// `127.0.0.1:27042` can reveal a running Frida server even when the dylib
/// has been renamed to evade the image scan.
///
/// - Warning: Sophisticated Frida setups rename the gadget and change the port.
///   Use this alongside `JailbreakDetectionManager` and `DebugDetectionManager`
///   for layered coverage.
struct ReverseEngineeringDetector: ReverseEngineeringDetecting {
    static let shared = ReverseEngineeringDetector()

    init() {}

    // MARK: - Indicator

    enum Indicator: String, CaseIterable, Sendable {
        case fridaDetected      = "Frida instrumentation framework detected"
        case hookingLibrary     = "Runtime hooking library detected (Substrate/Substitute/libhooker)"
        case sslBypass          = "SSL bypass tool detected (SSLKillSwitch)"
        case uiInspectionTool   = "UI inspection tool detected (Reveal)"
        case cycriptDetected    = "Cycript runtime detected"
        case fridaPortOpen      = "Frida server port 27042 is open on localhost"
    }

    // MARK: - ReverseEngineeringDetecting

    /// Returns `true` if any reverse-engineering indicator is found.
    var isUnderAttack: Bool { !detectedIndicators.isEmpty }

    /// All indicators that triggered during the scan.
    var detectedIndicators: [Indicator] {
        let images = loadedImageNames
        var found: [Indicator] = []
        if images.contains(where: isFridaDylib)    { found.append(.fridaDetected) }
        if images.contains(where: isHookingDylib)  { found.append(.hookingLibrary) }
        if images.contains(where: isSSLBypassDylib) { found.append(.sslBypass) }
        if images.contains(where: isRevealDylib)   { found.append(.uiInspectionTool) }
        if images.contains(where: isCycriptDylib)  { found.append(.cycriptDetected) }
        if isFridaPortReachable                    { found.append(.fridaPortOpen) }
        return found
    }

    // MARK: - Dylib Scan

    /// Enumerates all dynamic libraries loaded into the current process.
    private var loadedImageNames: [String] {
        (0..<_dyld_image_count()).compactMap { index in
            _dyld_get_image_name(index).map { String(cString: $0).lowercased() }
        }
    }

    private func isFridaDylib(_ name: String) -> Bool {
        name.contains("frida") || name.contains("gadget")
    }

    private func isHookingDylib(_ name: String) -> Bool {
        name.contains("mobilesubstrate") ||
        name.contains("substrate") ||
        name.contains("libsubstitute") ||
        name.contains("libhooker") ||
        name.contains("substituteloader")
    }

    private func isSSLBypassDylib(_ name: String) -> Bool {
        name.contains("sslkillswitch") || name.contains("ssl_kill_switch")
    }

    private func isRevealDylib(_ name: String) -> Bool {
        name.contains("revealserver") || name.contains("reveal2server")
    }

    private func isCycriptDylib(_ name: String) -> Bool {
        name.contains("cynject") || name.contains("cycript")
    }

    // MARK: - Frida Port Probe

    /// Attempts a non-blocking TCP connect to Frida's default port (27042).
    ///
    /// A reachable port suggests a Frida server is running, even if the Frida dylib
    /// has been renamed. The connect attempt is made with a non-blocking socket so
    /// it returns immediately (EINPROGRESS on success, ECONNREFUSED if nothing is listening).
    private var isFridaPortReachable: Bool {
        let sockfd = socket(AF_INET, SOCK_STREAM, 0)
        guard sockfd != -1 else { return false }
        defer { close(sockfd) }

        // Set socket to non-blocking so the attempt doesn't stall the app
        let flags = fcntl(sockfd, F_GETFL, 0)
        let result = fcntl(sockfd, F_SETFL, flags | O_NONBLOCK)
        // If setting non-blocking fails, proceed with best-effort (socket stays blocking)
        if result == -1 {
            // Failed to set non-blocking; avoid a potentially blocking connect
            return false
        }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = CFSwapInt16HostToBig(27042)
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let connectResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sockfd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        // connect() == 0 → immediate success (unusual for TCP)
        // errno == EINPROGRESS → handshake started — something is listening
        // errno == ECONNREFUSED → nothing is listening (expected safe case)
        return connectResult == 0 || errno == EINPROGRESS
    }
}

