import SwiftUI

/// Settings > Wi-Fi > [Network] — matches iPadOS 26:
/// Weak Security card, Forget This Network, Auto-Join + Password,
/// Low Data Mode, Private Wi-Fi Address, Limit IP Tracking, IPv4/DNS/Proxy.
struct NetworkDetailView: View {
    let network: MockWiFiNetwork
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmForget = false
    @State private var privateAddress = "Rotating"
    @State private var configureIP = "kWFLocSettingsIPV4ConfigureAutomatic"
    @State private var configureDNS = "kWFLocSettingsDNSSettingsAutomatic"
    @State private var configureProxy = "kWFLocGlobalProxyOff"

    private var ssidKey: String { network.ssid.replacingOccurrences(of: " ", with: "_") }
    private var isKnown: Bool { store.knownNetworkSSIDs.contains(network.ssid) }
    private var isConnected: Bool { store.connectedSSID == network.ssid }

    /// Deterministic per-SSID address so the value never changes between renders.
    private var ipv4Address: String {
        let sum = network.ssid.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return "192.168.\(sum % 200 + 10).\(sum % 150 + 20)"
    }

    var body: some View {
        List {
            // MARK: Weak Security warning
            if network.isWeak {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weak Security").font(.headline)
                        Text("WPA/WPA2 (TKIP) is not considered secure.")
                        Text("If this is your Wi-Fi network, configure the router to use WPA2 (AES) or WPA3 security type.")
                            .padding(.top, 6)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                } footer: {
                    Text("Learn more about recommended settings for Wi-Fi…")
                        .foregroundStyle(.blue)
                }
            }

            // MARK: Forget This Network
            if isKnown {
                Section {
                    Button("Forget This Network") { confirmForget = true }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // MARK: Auto-Join + Password
            Section {
                ToggleRow(title: "Auto-Join", key: "wifi.\(ssidKey).autoJoin", def: true)
                if network.security.isSecured {
                    LabeledContent("Password", value: "••••••••••••")
                }
            }

            // MARK: Low Data Mode
            Section {
                ToggleRow(title: "Low Data Mode", key: "wifi.\(ssidKey).lowData", def: false)
            } footer: {
                Text("Low Data Mode helps reduce your \(MockDevice.current.deviceTypeName) data usage over your cellular network or specific Wi-Fi networks you select. When Low Data Mode is turned on, automatic updates and background tasks, such as Photos syncing, are paused.")
            }

            // MARK: Private Wi-Fi Address
            Section {
                NavigationLink {
                    CheckmarkOptionListView(
                        title: "Private Wi-Fi Address",
                        options: ["Off", "Fixed", "Rotating"],
                        selection: $privateAddress
                    )
                } label: {
                    LabeledContent("Private Wi-Fi Address", value: privateAddress)
                }
                LabeledContent("Wi-Fi Address", value: MockDeviceIdentity.stored.wifiAddress)
            } footer: {
                Text("Wi-Fi networks and devices can track other nearby Wi-Fi devices by their Wi-Fi address, even on secure networks. A rotating private address reduces tracking by periodically changing this device's Wi-Fi address on this network.")
            }

            // MARK: Limit IP Address Tracking
            if privateAddress != "Off" {
                Section {
                    ToggleRow(title: "Limit IP Address Tracking", key: "wifi.\(ssidKey).limitIP", def: true)
                } footer: {
                    Text("Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari.")
                }
            }

            // MARK: IPv4 Address
            if isConnected {
                Section(header: Text("IPv4 Address").textCase(nil)) {
                    NavigationLink { ConfigureIPView(selected: $configureIP) } label: {
                        LabeledContent("Configure IP", value: configureIP.contains("Manual") ? "Manual" : "Automatic")
                    }
                    LabeledContent("IP Address", value: ipv4Address)
                    LabeledContent("Subnet Mask", value: "255.255.255.0")
                    LabeledContent("Router", value: "192.168.1.1")
                }

                Section(header: Text("DNS").textCase(nil)) {
                    NavigationLink { ConfigureDNSView(selected: $configureDNS) } label: {
                        LabeledContent("Configure DNS", value: configureDNS.contains("Manual") ? "Manual" : "Automatic")
                    }
                }

                Section(header: Text("HTTP Proxy").textCase(nil)) {
                    NavigationLink { ConfigureProxyView(selected: $configureProxy) } label: {
                        LabeledContent("Configure Proxy", value: configureProxy.contains("Off") ? "Off" : "Manual")
                    }
                }
            }

        }
        .navigationTitle(network.ssid)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            privateAddress = UserDefaults.standard.string(forKey: "wifi.\(ssidKey).private") ?? "Rotating"
        }
        .onChange(of: privateAddress) { _, value in
            UserDefaults.standard.set(value, forKey: "wifi.\(ssidKey).private")
        }
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
