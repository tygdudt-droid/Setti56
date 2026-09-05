import SwiftUI

struct NetworkDetailView: View {
    let network: MockWiFiNetwork
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmForget = false

    private var ssidKey: String { network.ssid.replacingOccurrences(of: " ", with: "_") }
    private var isKnown: Bool { store.knownNetworkSSIDs.contains(network.ssid) }
    private var isConnected: Bool { store.connectedSSID == network.ssid }

    var body: some View {
        List {
            if isKnown {
                Section { Button("Forget This Network", role: .destructive) { confirmForget = true } }
            }
            Section {
                ToggleRow(title: "Auto-Join", key: "wifi.\(ssidKey).autoJoin", def: true)
                ToggleRow(title: "Low Data Mode", key: "wifi.\(ssidKey).lowData", def: false)
            } footer: {
                Text("Low Data Mode helps reduce your \(MockDevice.current.deviceTypeName) data usage over your cellular network or specific Wi-Fi networks you select.")
            }
            Section {
                PickerRow(title: "Private Wi-Fi Address", key: "wifi.\(ssidKey).private", options: ["Off", "Fixed", "Rotating"], def: "Fixed")
                LabeledContent("Wi-Fi Address", value: MockDeviceIdentity.stored.wifiAddress)
                ToggleRow(title: "Limit IP Address Tracking", key: "wifi.\(ssidKey).limitIP", def: true)
            } footer: {
                Text("Using a private address helps reduce tracking of your \(MockDevice.current.deviceTypeName) across different Wi-Fi networks.")
            }
            if isConnected {
                Section("IPv4 Address") {
                    LabeledContent("Configure IP", value: "Automatic")
                    LabeledContent("IP Address", value: "192.168.1.\(Int.random(in: 20...200))")
                    LabeledContent("Subnet Mask", value: "255.255.255.0")
                    LabeledContent("Router", value: "192.168.1.1")
                }
                Section("DNS") { LabeledContent("Configure DNS", value: "Automatic") }
                Section("HTTP Proxy") { LabeledContent("Configure Proxy", value: "Off") }
            }
            Section { LabeledContent("Security", value: network.security.label) }
        }
        .navigationTitle(network.ssid)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Forget Wi-Fi Network “\(network.ssid)”?", isPresented: $confirmForget, titleVisibility: .visible) {
            Button("Forget", role: .destructive) { WiFiEngine.shared.forget(network.ssid); dismiss() }
        } message: {
            Text("Your \(MockDevice.current.deviceTypeName) will no longer join this Wi-Fi network.")
        }
    }
}

extension WiFiEngine {
    @MainActor static let shared = WiFiEngine()
}

private struct ToggleRow: View {
    let title: String; let key: String; let def: Bool
    var body: some View {
        Toggle(title, isOn: Binding(
            get: { UserDefaults.standard.object(forKey: key) as? Bool ?? def },
            set: { UserDefaults.standard.set($0, forKey: key) }))
    }
}

private struct PickerRow: View {
    let title: String; let key: String; let options: [String]; let def: String
    @State private var value = ""
    var body: some View {
        Picker(title, selection: $value) { ForEach(options, id: \.self) { Text($0) } }
            .onAppear { value = UserDefaults.standard.string(forKey: key) ?? def }
            .onChange(of: value) { _, v in UserDefaults.standard.set(v, forKey: key) }
    }
}
