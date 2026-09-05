//
//  VPNView.swift
//  Preferences
//
//  Settings > VPN
//

import SwiftUI

/// View for Settings > VPN (mock, always-connected profile).
struct VPNView: View {
    @AppStorage("VPN") private var vpnEnabled = true
    @State private var showDetails = false
    private var deviceName: String { UIDevice.current.name.isEmpty ? "iPad" : UIDevice.current.name }

    var body: some View {
        CustomList(title: "VPN", topPadding: true) {
            Section {
                LabeledContent("Status", value: vpnEnabled ? "Connected" : "Not Connected")
                if vpnEnabled {
                    LabeledContent("Connection Type", value: "IKEv2")
                    LabeledContent("Duration", value: "04:26:31")
                }
            } header: {
                Text("VPN Configurations")
            } footer: {
                Text(vpnEnabled
                     ? "A VPN connection routes all of your activity through a secure server. Websites and apps see the VPN server address instead of your real one."
                     : "Turn on a VPN configuration to route your activity through a secure server.")
            }

            Section {
                NavigationLink {
                    VPNConfigurationDetailView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "globe.badge.chevron.backward")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 29, height: 29)
                            .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.blue))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deviceName)
                            Text(vpnEnabled ? "Connected" : "Disconnected")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Section {
                Toggle("VPN On Demand", isOn: .constant(vpnEnabled))
                Toggle("Allow VPN Over Cellular", isOn: .constant(true))
            } footer: {
                Text("VPN configurations use IKEv2 with a certificate for authentication.")
            }
        }
    }
}

/// Mock detail page for the installed VPN profile.
struct VPNConfigurationDetailView: View {
    var body: some View {
        CustomList(title: UIDevice.current.name, topPadding: true) {
            Section {
                LabeledContent("Status", value: "Connected")
                LabeledContent("Server", value: "vpn.icloud-mock.net")
                LabeledContent("Account", value: "Mock User")
                LabeledContent("Certificate", value: "Valid")
            } header: {
                Text("Details")
            }

            Section {
                LabeledContent("Remote ID", value: "vpn.icloud-mock.net")
                LabeledContent("Local ID", value: "—")
                LabeledContent("Type", value: "IKEv2")
            }

            Section {
                Button("Disconnect", role: .destructive) {}
            }
        }
    }
}

#Preview {
    NavigationStack {
        VPNView()
    }
}
