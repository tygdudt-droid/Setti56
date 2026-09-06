//
//  ConfigureDNSView.swift
//  Preferences
//
//  Settings > Wi-Fi > [info.circle] > Configure DNS
//

import SwiftUI

struct ConfigureDNSView: View {
    @Binding var selected: String
    @State private var isAutomatic = true
    @State private var dnsServers: [DNSServer] = []
    @State private var searchDomains: [SearchDomain] = []
    @State private var addServerSheet = false
    @State private var addDomainSheet = false
    @State private var newServer = ""
    @State private var newDomain = ""

    var body: some View {
        CustomList(title: "Configure DNS", topPadding: true) {
            Section {
                Button {
                    isAutomatic = true
                } label: {
                    HStack {
                        Text("Automatic").foregroundStyle(.primary)
                        Spacer()
                        if isAutomatic { Image(systemName: "checkmark").foregroundStyle(.blue) }
                    }
                }
                Button {
                    isAutomatic = false
                } label: {
                    HStack {
                        Text("Manual").foregroundStyle(.primary)
                        Spacer()
                        if !isAutomatic { Image(systemName: "checkmark").foregroundStyle(.blue) }
                    }
                }
            }

            Section(header: Text("DNS Servers").textCase(nil)) {
                if !isAutomatic {
                    ForEach($dnsServers) { $server in
                        TextField("Server", text: $server.server)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .onDelete { dnsServers.remove(atOffsets: $0) }

                    Button {
                        addServerSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                            Text("Add Server")
                        }
                    }
                }
            }

            Section(header: Text("Search Domains").textCase(nil)) {
                if !isAutomatic {
                    ForEach($searchDomains) { $domain in
                        TextField("Domain", text: $domain.domain)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .onDelete { searchDomains.remove(atOffsets: $0) }

                    Button {
                        addDomainSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                            Text("Add Search Domain")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    selected = isAutomatic ? "kWFLocSettingsDNSSettingsAutomatic" : "kWFLocSettingsDNSSettingsManual"
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            isAutomatic = !selected.contains("Manual")
        }
        .alert("Add Server", isPresented: $addServerSheet) {
            TextField("DNS Server", text: $newServer)
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
            Button("Add") {
                let v = newServer.trimmingCharacters(in: .whitespaces)
                if !v.isEmpty { dnsServers.append(DNSServer(server: v)) }
                newServer = ""
            }
            Button("Cancel", role: .cancel) { newServer = "" }
        }
        .alert("Add Search Domain", isPresented: $addDomainSheet) {
            TextField("Domain", text: $newDomain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Add") {
                let v = newDomain.trimmingCharacters(in: .whitespaces)
                if !v.isEmpty { searchDomains.append(SearchDomain(domain: v)) }
                newDomain = ""
            }
            Button("Cancel", role: .cancel) { newDomain = "" }
        }
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
