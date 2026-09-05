import SwiftUI

/// Settings > Wi-Fi — matches iPadOS 26:
/// placard card with the toggle and the connected network inside,
/// then My Networks, Networks (Other…), Ask to Join, and Auto-Join Hotspot.
struct WiFiView: View {
    @Environment(SettingsStore.self) private var store
    @State private var engine = WiFiEngine()
    @State private var joining: MockWiFiNetwork?
    @State private var titleVisible = false
    @State private var showingHelpSheet = false
    @AppStorage("wifi.askToJoin") private var askToJoin = "Notify"
    @AppStorage("wifi.autoHotspot") private var autoHotspot = "Automatic"

    private var connectedNetwork: MockWiFiNetwork? {
        WiFiEngine.network(for: store.connectedSSID)
    }
    private var knownNetworks: [MockWiFiNetwork] {
        engine.visible.filter { store.knownNetworkSSIDs.contains($0.ssid) && $0.ssid != store.connectedSSID }
    }
    private var otherNetworks: [MockWiFiNetwork] {
        engine.visible.filter { !store.knownNetworkSSIDs.contains($0.ssid) }
    }

    var body: some View {
        @Bindable var store = store
        CustomList(title: titleVisible ? "Wi-Fi" : "", topPadding: true) {
            // MARK: Placard + toggle + connected network (one card)
            Section {
                Placard(
                    title: "Wi-Fi",
                    icon: "com.apple.graphic-icon.wifi",
                    description: "Connect to Wi-Fi, view available networks, and manage settings for joining networks and nearby hotspots. [Learn more...](pref://wifi-help)",
                    isVisible: $titleVisible
                )

                Toggle("Wi-Fi", isOn: $store.wifiEnabled)

                if store.wifiEnabled, let net = connectedNetwork {
                    NetworkRow(network: net, state: .connected, subtitle: net.isWeak ? "Weak Security" : "")
                }
            } footer: {
                if !store.wifiEnabled {
                    Text("Turn on Wi-Fi to see available networks.")
                }
            }

            if store.wifiEnabled {
                // MARK: My Networks
                if !knownNetworks.isEmpty {
                    Section(header: Text("My Networks").textCase(nil)) {
                        ForEach(knownNetworks) { net in
                            NetworkRow(network: net, state: .idle, subtitle: net.isWeak ? "Weak Security" : "") { joining = net }
                        }
                    }
                }

                // MARK: Networks / Other…
                Section(header: Text("Networks").textCase(nil)) {
                    ForEach(otherNetworks) { net in
                        NetworkRow(network: net, state: .idle, subtitle: net.isWeak ? "Weak Security" : "") { joining = net }
                    }
                    if engine.scanning {
                        HStack(spacing: 10) {
                            Color.clear.frame(width: 20)
                            Text("Scanning…")
                            Spacer()
                            ProgressView()
                        }
                        .foregroundStyle(.secondary)
                    }
                    NavigationLink("Other…") { OtherNetworkView() }
                }

                // MARK: Ask to Join Networks
                Section {
                    NavigationLink {
                        CheckmarkOptionListView(
                            title: "Ask to Join Networks",
                            options: ["Off", "Notify", "Ask"],
                            selection: $askToJoin
                        )
                    } label: {
                        LabeledContent("Ask to Join Networks", value: askToJoin)
                    }
                } footer: {
                    Text("Known networks will be joined automatically. If no known networks are available, you will be notified of available networks.")
                }

                // MARK: Auto-Join Hotspot
                Section {
                    NavigationLink {
                        CheckmarkOptionListView(
                            title: "Auto-Join Hotspot",
                            options: ["Never", "Ask to Join", "Automatic"],
                            selection: $autoHotspot
                        )
                    } label: {
                        LabeledContent("Auto-Join Hotspot", value: autoHotspot)
                    }
                } footer: {
                    Text("Allow this device to automatically discover nearby personal hotspots when no Wi-Fi network is available.")
                }
            }
        }
        .toolbar {
            if store.wifiEnabled {
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
            }
        }
        .sheet(item: $joining) { JoinNetworkSheet(network: $0, engine: engine) }
        .onOpenURL { _ in showingHelpSheet.toggle() }
        .sheet(isPresented: $showingHelpSheet) {
            HLPHelpViewController(topicID: UIDevice.iPhone ? "iphd1cf4268" : "ipad2db29c3a")
                .ignoresSafeArea(edges: .bottom)
                .interactiveDismissDisabled()
        }
        .task { engine.startScanning() }
        .onChange(of: store.wifiEnabled) { _, on in on ? engine.startScanning() : engine.stopScanning() }
        .onDisappear { engine.stopScanning() }
    }
}

/// Simple checkmark selection page (Ask to Join, Auto-Join Hotspot, …).
struct CheckmarkOptionListView: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CustomList(title: title, topPadding: true) {
            Section {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                        dismiss()
                    } label: {
                        HStack {
                            Text(option).foregroundStyle(.primary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark").foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WiFiView()
    }
}
