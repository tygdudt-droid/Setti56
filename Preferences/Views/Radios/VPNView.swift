//
//  VPNView.swift
//  Preferences
//
//  Settings > VPN
//

import SwiftUI

/// One VPN configuration row (app-provided "Device VPN" or "Personal VPN").
struct MockVPNConfig: Identifiable, Codable, Hashable {
    var id: String { name }
    var name: String
    var app: String          // subtitle: providing app / description
    var type: String = "IKEv2"
    var server: String = ""
}

/// Settings > VPN — iPadOS 26 layout:
/// VPN Status card, "Device VPN" list of app configurations (checkmark on the
/// active one, ⓘ pushes details), "Personal VPN" status card, personal
/// configurations, and "Add VPN Configuration…".
struct VPNView: View {
    @AppStorage("VPN") private var vpnEnabled = true
    @AppStorage("vpn.personal.enabled") private var personalEnabled = false
    @AppStorage("vpn.device.selected") private var selectedDevice = "JumpJump"
    @AppStorage("vpn.personal.selected") private var selectedPersonal = "Free VPN"
    @State private var personalConfigs: [MockVPNConfig] = VPNView.defaultPersonal
    @State private var showAdd = false

    static let deviceConfigs: [MockVPNConfig] = [
        MockVPNConfig(name: "JumpJump", app: "JumpJumpVPN", type: "WireGuard", server: "jp1.jumpjump.app"),
        MockVPNConfig(name: "Npv Tunnel", app: "Npv Tunnel", type: "IKEv2", server: "tunnel.npv.io"),
        MockVPNConfig(name: "Psiphon", app: "Psiphon", type: "SSH+", server: "psiphon3.com"),
        MockVPNConfig(name: "SkyVPN", app: "SkyVPN", type: "OpenVPN", server: "us.skyvpn.net"),
        MockVPNConfig(name: "Turbo VPN", app: "Turbo VPN", type: "OpenVPN", server: "de.turbovpn.com"),
        MockVPNConfig(name: "V2BOX", app: "V2BOX", type: "VLESS", server: "v2box.app"),
        MockVPNConfig(name: "VPN Super - OpenVPN", app: "VPN Super", type: "OpenVPN", server: "ovpn.vpnsuper.io"),
        MockVPNConfig(name: "VPNIFY", app: "vpnify", type: "IKEv2", server: "nl.vpnify.com"),
        MockVPNConfig(name: "X-VPN", app: "X-VPN", type: "Everest", server: "x-vpn.com")
    ]

    static let defaultPersonal: [MockVPNConfig] = [
        MockVPNConfig(name: "Free VPN", app: "Free VPN", type: "IKEv2", server: "free.vpn.example"),
        MockVPNConfig(name: "Turbo VPN", app: "Turbo VPN", type: "IKEv2", server: "ikev2.turbovpn.com"),
        MockVPNConfig(name: "VPN Super - IKEv2", app: "VPN Super", type: "IKEv2", server: "ikev2.vpnsuper.io")
    ]

    private var activeDevice: MockVPNConfig? {
        Self.deviceConfigs.first { $0.name == selectedDevice } ?? Self.deviceConfigs.first
    }

    var body: some View {
        CustomList(title: "VPN", topPadding: true) {
            // MARK: VPN Status
            Section {
                HStack {
                    Text("VPN Status")
                    Spacer()
                    Text(vpnEnabled ? "Connected" : "Not Connected")
                        .foregroundStyle(.secondary)
                    Toggle("", isOn: $vpnEnabled)
                        .labelsHidden()
                        .padding(.leading, 8)
                }
            } footer: {
                if let activeDevice {
                    Text("To connect using “\(activeDevice.name)”, use the “\(activeDevice.app)” application.")
                }
            }

            // MARK: Device VPN
            Section {
                ForEach(Self.deviceConfigs) { config in
                    VPNConfigRow(config: config, selected: config.name == selectedDevice) {
                        selectedDevice = config.name
                    }
                }
            } header: {
                sectionHeader("Device VPN")
            }

            // MARK: Personal VPN
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(personalEnabled ? "Connected" : "Not Connected")
                        .foregroundStyle(.secondary)
                    Toggle("", isOn: $personalEnabled)
                        .labelsHidden()
                        .padding(.leading, 8)
                }
            } header: {
                sectionHeader("Personal VPN")
            }

            Section {
                ForEach(personalConfigs) { config in
                    VPNConfigRow(config: config, selected: config.name == selectedPersonal) {
                        selectedPersonal = config.name
                    }
                }
                .onDelete { offsets in
                    personalConfigs.remove(atOffsets: offsets)
                }
            }

            Section {
                Button("Add VPN Configuration...") { showAdd = true }
            } footer: {
                Text("VPNs can be set up to control the routing of certain network traffic. [About VPNs & Privacy...](https://www.apple.com/legal/privacy/data/)")
            }
        }
        .sheet(isPresented: $showAdd) {
            AddVPNConfigurationSheet { config in
                personalConfigs.append(config)
                selectedPersonal = config.name
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
}

/// Checkmark + name/app + ⓘ. Tapping the row selects it; ⓘ opens details.
struct VPNConfigRow: View {
    let config: MockVPNConfig
    let selected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                        .opacity(selected ? 1 : 0)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.name)
                        Text(config.app)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.primary)

            PushButton("VPN/\(config.name)") {
                VPNConfigurationDetailView(config: config)
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 2)
    }
}

/// Settings > VPN > ⓘ
struct VPNConfigurationDetailView: View {
    let config: MockVPNConfig
    @AppStorage("VPN") private var vpnEnabled = true

    var body: some View {
        CustomList(title: config.name, topPadding: true) {
            Section {
                LabeledContent("Type", value: config.type)
                LabeledContent("Server", value: config.server.isEmpty ? "—" : config.server)
                LabeledContent("Provided by", value: config.app)
                LabeledContent("Status", value: vpnEnabled ? "Connected" : "Not Connected")
            }
            Section {
                Toggle("Connect On Demand", isOn: .constant(true))
            } footer: {
                Text("Connect On Demand lets the “\(config.app)” app start this VPN automatically when needed.")
            }
            Section {
                Button("Delete VPN", role: .destructive) {}
            }
        }
    }
}

/// Settings > VPN > Add VPN Configuration…
struct AddVPNConfigurationSheet: View {
    var onAdd: (MockVPNConfig) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var type = "IKEv2"
    @State private var descriptionText = ""
    @State private var server = ""
    @State private var remoteID = ""
    @State private var localID = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(["IKEv2", "IPsec", "L2TP"], id: \.self) { Text($0) }
                    }
                }
                Section {
                    LabeledContent("Description") {
                        TextField("Required", text: $descriptionText).multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Server") {
                        TextField("Required", text: $server).multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
                    }
                    LabeledContent("Remote ID") {
                        TextField("Required", text: $remoteID).multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
                    }
                    LabeledContent("Local ID") {
                        TextField("", text: $localID).multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
                    }
                }
                Section {
                    LabeledContent("Username") {
                        TextField("Required", text: $username).multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
                    }
                    LabeledContent("Password") {
                        SecureField("Ask Every Time", text: $password).multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Authentication").textCase(nil)
                }
            }
            .navigationTitle("Add Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onAdd(MockVPNConfig(name: descriptionText, app: descriptionText, type: type, server: server))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(descriptionText.isEmpty || server.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VPNView()
    }
    .environment(PrimarySettingsListModel())
}
