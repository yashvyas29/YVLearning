//
//  DebugDetectionManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import Foundation
import Darwin

// MARK: - Protocol

/// Abstraction over debug/tamper detection. Conform a mock to this in tests.
protocol DebugDetecting {
    var isDebugged: Bool { get }
    var isRunningOnSimulator: Bool { get }
    var detectedIndicators: [DebugDetectionManager.Indicator] { get }
}

// MARK: - Implementation

/// Detects whether the app is being debugged, running in the simulator, or operating
/// in an environment that indicates reverse-engineering or tampering.
///
/// ## Checks Performed
///
/// | Indicator | Method | Notes |
/// |-----------|--------|-------|
/// | `debuggerAttached` | `sysctl(KERN_PROC_PID)` P_TRACED flag | Triggers under Xcode/lldb |
/// | `ttyAttached` | `isatty()` on stdin/stdout/stderr | Triggers when Xcode console is attached |
/// | `simulator` | `SIMULATOR_DEVICE_NAME` env var | Reliable runtime simulator check |
///
/// ## Recommended Usage
///
/// All indicators trigger during normal Xcode development runs. Only use this manager
/// in **release builds** to gate sensitive features:
///
/// ```swift
/// #if !DEBUG
/// if DebugDetectionManager.shared.isDebugged {
///     // Restrict sensitive feature or terminate
/// }
/// #endif
/// ```
///
/// - Warning: `sysctl`-based detection can be bypassed by tools that clear the P_TRACED flag
///   at the kernel level. Treat results as a heuristic, not a cryptographic guarantee.
struct DebugDetectionManager: DebugDetecting {
    static let shared = DebugDetectionManager()

    init() {}

    // MARK: - Indicator

    enum Indicator: String, CaseIterable, Sendable {
        case debuggerAttached = "Debugger attached (P_TRACED flag set via sysctl)"
        case ttyAttached      = "Process stdin/stdout/stderr is connected to a TTY"
        case simulator        = "Running in the iOS Simulator"
    }

    // MARK: - DebugDetecting

    /// Returns `true` if a debugger or tampering indicator is detected.
    /// Simulator-only presence is excluded — being on the simulator is not a threat in itself.
    var isDebugged: Bool {
        detectedIndicators.contains { $0 != .simulator }
    }

    /// Returns `true` when the process is running inside the iOS Simulator.
    var isRunningOnSimulator: Bool { hasSimulatorEnvironment }

    /// All indicators that triggered, including the simulator flag.
    var detectedIndicators: [Indicator] {
        var found: [Indicator] = []
        if hasDebuggerAttached     { found.append(.debuggerAttached) }
        if hasControllingTTY       { found.append(.ttyAttached) }
        if hasSimulatorEnvironment { found.append(.simulator) }
        return found
    }

    // MARK: - Private Checks

    /// Queries the kernel for the current process's flags using `sysctl`.
    /// The `P_TRACED` flag (`0x00000800`) is set when a debugger such as lldb has attached.
    ///
    /// This is the standard approach used by Apple's own `ptrace`-based security APIs.
    private var hasDebuggerAttached: Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        guard sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0 else { return false }
        // P_TRACED = 0x00000800 (from <sys/proc.h>)
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    /// A TTY connected to stdin/stdout/stderr is characteristic of a process launched
    /// interactively or via a debugger. SpringBoard-launched apps on a physical device
    /// have no controlling terminal.
    private var hasControllingTTY: Bool {
        isatty(STDIN_FILENO) != 0 || isatty(STDOUT_FILENO) != 0 || isatty(STDERR_FILENO) != 0
    }

    /// The iOS Simulator injects `SIMULATOR_DEVICE_NAME` into the process environment.
    /// Checking this at runtime avoids a compile-time `#if targetEnvironment(simulator)`,
    /// which would be stripped from release builds.
    private var hasSimulatorEnvironment: Bool {
        ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}
