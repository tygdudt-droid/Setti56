import SwiftUI

struct OtherNetworkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var security = "WPA2/WPA3"
    @State private var password = ""
    @State private var joining = false

    var body: some View {
        List {
            Section("Name") { TextField("Network Name", text: $name) }
            Section("Security") {
                Picker("Security", selection: $security) {
                    ForEach(["None", "WEP", "WPA", "WPA2/WPA3", "WPA3", "WPA2 Enterprise"], id: \.self) { Text($0) }
                }
            }
            if security != "None" {
                Section("Password") { SecureField("Password", text: $password) }
            }
        }
        .navigationTitle("Other Network")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if joining { ProgressView() } else {
                    Button("Join") {
                        joining = true
                        Task {
                            let net = MockWiFiNetwork(ssid: name, security: security == "None" ? .none : .wpa2, signal: 2, isHotspot: false)
                            do {
                                try await WiFiEngine.shared.join(net, password: security == "None" ? nil : password)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                dismiss()
                            } catch {
                                // Stay on the sheet so the user can retry the password.
                            }
                            joining = false
                        }
                    }
                    .disabled(name.isEmpty || (security != "None" && password.count < 8))
                }
            }
        }
    }
}
