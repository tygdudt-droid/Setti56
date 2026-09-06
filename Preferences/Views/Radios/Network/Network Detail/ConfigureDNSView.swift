//
//  ConfigureDNSView.swift
//  Preferences
//
//  Settings > Wi-Fi > [info.circle] > Configure DNS
//

import SwiftUI

/// iPadOS 26 layout: Automatic / Manual card, then "DNS Servers" and
/// "Search Domains" cards. In Manual mode each entry is an inline editable
/// row with a red delete control, and the green "Add …" row appends a new
/// empty row and focuses it (no alert), exactly like iOS.
struct ConfigureDNSView: View {
    @Binding var selected: String
    @State private var isAutomatic = true
    @State private var dnsServers: [DNSServer] = []
    @State private var searchDomains: [SearchDomain] = []
    @FocusState private var focusedServer: UUID?
    @FocusState private var focusedDomain: UUID?

    var body: some View {
        CustomList(title: "Configure DNS", topPadding: true) {
            Section {
                modeRow("Automatic", selected: isAutomatic) { isAutomatic = true }
                modeRow("Manual", selected: !isAutomatic) { isAutomatic = false }
            }

            Section {
                if !isAutomatic {
                    ForEach($dnsServers) { $server in
                        HStack(spacing: 18) {
                            deleteButton { dnsServers.removeAll { $0.id == server.id } }
                            TextField("DNS Server", text: $server.server)
                                .focused($focusedServer, equals: server.id)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.numbersAndPunctuation)
                        }
                    }
                    addRow("Add Server") {
                        let s = DNSServer(server: "")
                        dnsServers.append(s)
                        focusedServer = s.id
                    }
                } else {
                    Text("Automatically obtained from the router.")
                        .foregroundStyle(.secondary)
                }
            } header: {
                sectionHeader("DNS Servers")
            }

            Section {
                if !isAutomatic {
                    ForEach($searchDomains) { $domain in
                        HStack(spacing: 18) {
                            deleteButton { searchDomains.removeAll { $0.id == domain.id } }
                            TextField("Search Domain", text: $domain.domain)
                                .focused($focusedDomain, equals: domain.id)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                        }
                    }
                    addRow("Add Search Domain") {
                        let d = SearchDomain(domain: "")
                        searchDomains.append(d)
                        focusedDomain = d.id
                    }
                } else {
                    Text("Automatically obtained from the router.")
                        .foregroundStyle(.secondary)
                }
            } header: {
                sectionHeader("Search Domains")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    dnsServers.removeAll { $0.server.trimmingCharacters(in: .whitespaces).isEmpty }
                    searchDomains.removeAll { $0.domain.trimmingCharacters(in: .whitespaces).isEmpty }
                    selected = isAutomatic ? "kWFLocSettingsDNSSettingsAutomatic" : "kWFLocSettingsDNSSettingsManual"
                }
            }
        }
        .onAppear {
            isAutomatic = !selected.contains("Manual")
        }
    }

    // MARK: Pieces

    private func modeRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundStyle(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }
            .contentShape(Rectangle())
        }
    }

    /// Green ⊕ + label, like the insert row in iOS grouped lists.
    private func addRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 18) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white, .green)
                Text(title).foregroundStyle(.primary)
            }
            .contentShape(Rectangle())
        }
    }

    /// Red ⊖ delete control at the leading edge of an editable row.
    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white, .red)
        }
        .buttonStyle(.borderless)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
}

// MARK: - Identifiable structs
struct DNSServer: Identifiable {
    var id = UUID()
    var server: String
}

struct SearchDomain: Identifiable {
    var id = UUID()
    var domain: String
}

#Preview {
    NavigationStack {
        ConfigureDNSView(selected: .constant("kWFLocSettingsDNSSettingsAutomatic"))
    }
}
