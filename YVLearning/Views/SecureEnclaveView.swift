//
//  SecureEnclaveView.swift
//  YVLearning
//
//  Created by Yash Vyas on 22/04/2026.
//

import SwiftUI
import CryptoKit

// MARK: - ViewModel

@available(iOS 17.0, *)
@Observable
@MainActor
final class SecureEnclaveViewModel {
    private let enclaveManager = SecureEnclaveManager.shared
    private let keychainManager = KeychainManager.shared

    private let keyTag = "com.yvlearning.demo.signing-key"
    private let tokenKeychainKey = "com.yvlearning.demo.auth-token"

    var message: String = "Hello, Secure Enclave!"
    var signatureHex: String = ""
    var statusMessage: String = ""
    var isSuccess: Bool = false
    var isEnclaveAvailable: Bool = false

    init() {
        isEnclaveAvailable = enclaveManager.isAvailable
    }

    // MARK: Secure Enclave

    func signMessage() {
        guard let data = message.data(using: .utf8) else { return }
        do {
            let privateKey = try enclaveManager.loadOrCreateKey(tag: keyTag)
            let signature = try enclaveManager.sign(data, with: privateKey)
            signatureHex = signature.rawRepresentation.hexString
            setStatus("Message signed successfully.", success: true)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    func verifySignature() {
        guard !signatureHex.isEmpty else {
            setStatus("Sign a message first.", success: false)
            return
        }
        guard let data = message.data(using: .utf8),
              let sigData = Data(hexString: signatureHex) else {
            setStatus("Invalid input data.", success: false)
            return
        }
        do {
            let privateKey = try enclaveManager.loadOrCreateKey(tag: keyTag)
            let signature = try P256.Signing.ECDSASignature(rawRepresentation: sigData)
            let isValid = enclaveManager.verify(signature, for: data, using: privateKey.publicKey)
            setStatus(isValid ? "Signature is valid." : "Signature is INVALID.", success: isValid)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    func deleteKey() {
        do {
            try enclaveManager.deleteKey(tag: keyTag)
            signatureHex = ""
            setStatus("Secure Enclave key deleted from Keychain.", success: true)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    // MARK: Keychain

    func saveToken() {
        let token = "yvl-token-\(Int.random(in: 10000...99999))"
        do {
            try keychainManager.saveString(token, for: tokenKeychainKey)
            setStatus("Token '\(token)' saved to Keychain.", success: true)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    func loadToken() {
        do {
            let token = try keychainManager.loadString(for: tokenKeychainKey)
            setStatus("Loaded token: \(token)", success: true)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    func deleteToken() {
        do {
            try keychainManager.delete(for: tokenKeychainKey)
            setStatus("Token deleted from Keychain.", success: true)
        } catch {
            setStatus(error.localizedDescription, success: false)
        }
    }

    // MARK: Private

    private func setStatus(_ message: String, success: Bool) {
        statusMessage = message
        isSuccess = success
    }
}

// MARK: - View

@available(iOS 17.0, *)
struct SecureEnclaveView: View {
    @State private var viewModel = SecureEnclaveViewModel()

    var body: some View {
        NavigationStack {
            Form {
                deviceSection
                messageSection
                signingSection
                keychainSection
                statusSection
            }
            .navigationTitle("Secure Enclave")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var deviceSection: some View {
        Section("Device Support") {
            LabeledContent("Secure Enclave") {
                Label(
                    viewModel.isEnclaveAvailable ? "Available" : "Not Available",
                    systemImage: viewModel.isEnclaveAvailable ? "lock.shield.fill" : "lock.slash"
                )
                .foregroundStyle(viewModel.isEnclaveAvailable ? .green : .red)
                .labelStyle(.titleAndIcon)
            }
        }
    }

    private var messageSection: some View {
        Section("Message to Sign") {
            TextField("Enter a message", text: $viewModel.message)
                .autocorrectionDisabled()
        }
    }

    private var signingSection: some View {
        Section {
            Button {
                viewModel.signMessage()
            } label: {
                Label("Sign with Secure Enclave", systemImage: "signature")
            }
            .disabled(!viewModel.isEnclaveAvailable || viewModel.message.isEmpty)

            if !viewModel.signatureHex.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("ECDSA Signature (P-256)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.signatureHex)
                        .font(.caption2)
                        .monospaced()
                        .lineLimit(4)
                        .textSelection(.enabled)
                }

                Button {
                    viewModel.verifySignature()
                } label: {
                    Label("Verify Signature", systemImage: "checkmark.seal")
                }

                Button(role: .destructive) {
                    viewModel.deleteKey()
                } label: {
                    Label("Delete Key from Keychain", systemImage: "trash")
                }
            }
        } header: {
            Text("Signing (Secure Enclave)")
        } footer: {
            Text("The P-256 private key is generated and stored inside the Secure Enclave. Only its wrapped reference is saved to the Keychain.")
                .font(.caption)
        }
    }

    private var keychainSection: some View {
        Section {
            Button {
                viewModel.saveToken()
            } label: {
                Label("Save Random Token", systemImage: "key.fill")
            }

            Button {
                viewModel.loadToken()
            } label: {
                Label("Load Token", systemImage: "arrow.down.doc")
            }

            Button(role: .destructive) {
                viewModel.deleteToken()
            } label: {
                Label("Delete Token", systemImage: "trash")
            }
        } header: {
            Text("Keychain")
        } footer: {
            Text("Stores and retrieves a generic password item using kSecClassGenericPassword with kSecAttrAccessibleWhenUnlockedThisDeviceOnly.")
                .font(.caption)
        }
    }

    private var statusSection: some View {
        Section("Status") {
            if viewModel.statusMessage.isEmpty {
                Text("Tap an action above to see results here.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                Label(viewModel.statusMessage, systemImage: viewModel.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(viewModel.isSuccess ? .green : .red)
                    .font(.callout)
            }
        }
    }
}

// MARK: - Hex Helpers

private extension Data {
    init?(hexString: String) {
        let clean = hexString.filter { $0.isHexDigit }
        guard clean.count % 2 == 0 else { return nil }
        var bytes: [UInt8] = []
        var index = clean.startIndex
        while index < clean.endIndex {
            let next = clean.index(index, offsetBy: 2)
            guard let byte = UInt8(clean[index..<next], radix: 16) else { return nil }
            bytes.append(byte)
            index = next
        }
        self.init(bytes)
    }

    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 17.0, *) {
        SecureEnclaveView()
    }
}
