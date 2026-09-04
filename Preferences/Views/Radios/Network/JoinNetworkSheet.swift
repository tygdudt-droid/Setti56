import SwiftUI

struct JoinNetworkSheet: View {
    let network: MockWiFiNetwork
    let engine: WiFiEngine
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var joining = false
    @State private var error: String?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            List {
                if network.security.isSecured {
                    Section {
                        if network.security == .enterprise {
                            TextField("Username", text: .constant("")).disabled(true)
                        }
                        SecureField("Password", text: $password).focused($focused)
                    } header: {
                        Text("Enter the password for “\(network.ssid)”")
                    } footer: {
                        Text("You can also access this Wi-Fi network by bringing your \(MockDevice.current.deviceTypeName) near any iPhone, iPad, or Mac that has connected to this network and has you in their contacts.")
                    }
                } else {
                    Section {
                        Text("“\(network.ssid)” is an unsecured network. Traffic may be visible to others.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(network.ssid)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(joining) }
                ToolbarItem(placement: .confirmationAction) {
                    if joining { ProgressView() } else {
                        Button("Join") { join() }.fontWeight(.semibold)
                            .disabled(network.security.isSecured && password.isEmpty)
                    }
                }
            }
            .alert("Unable to join the network “\(network.ssid)”", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("Dismiss", role: .cancel) {}
            } message: { Text(error ?? "") }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(joining)
    }

    private func join() {
        joining = true
        Task {
            do {
                try await engine.join(network, password: password)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            } catch {
                self.error = "Incorrect password for “\(network.ssid)”."
                password = ""
            }
            joining = false
        }
    }
}
