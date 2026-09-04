import SwiftUI

struct WiFiView: View {
    @Environment(SettingsStore.self) private var store
    @State private var engine = WiFiEngine()
    @State private var joining: MockWiFiNetwork?
    @AppStorage("wifi.askToJoin") private var askToJoin = "Ask"
    @AppStorage("wifi.autoHotspot") private var autoHotspot = "Ask to Join"

    var body: some View {
        @Bindable var store = store
        List {
            Section {
                Toggle("Wi-Fi", isOn: $store.wifiEnabled)
                if store.wifiEnabled, let net = WiFiEngine.network(for: store.connectedSSID) {
                    NetworkRow(network: net, state: .connected) { }
                }
            } footer: {
                if !store.wifiEnabled { Text("Turn on Wi-Fi to see available networks.") }
            }

            if store.wifiEnabled {
                let known = engine.visible.filter { store.knownNetworkSSIDs.contains($0.ssid) && $0.ssid != store.connectedSSID }
                if !known.isEmpty {
                    Section("My Networks") {
                        ForEach(known) { n in NetworkRow(network: n, state: .idle) { joining = n } }
                    }
                }

                Section {
                    ForEach(engine.visible.filter { !store.knownNetworkSSIDs.contains($0.ssid) }) { n in
                        NetworkRow(network: n, state: .idle) { joining = n }
                    }
                    NavigationLink("Other…") { OtherNetworkView() }
                } header: {
                    HStack(spacing: 8) {
                        Text("Other Networks")
                        if engine.scanning { ProgressView().controlSize(.mini) }
                    }
                }

                Section {
                    Picker("Ask to Join Networks", selection: $askToJoin) {
                        ForEach(["Off", "Notify", "Ask"], id: \.self) { Text($0) }
                    }
                    Picker("Auto-Join Hotspot", selection: $autoHotspot) {
                        ForEach(["Never", "Ask to Join", "Automatic"], id: \.self) { Text($0) }
                    }
                } footer: {
                    Text("Known networks will be joined automatically. If no known networks are available, you will be asked before joining a new network.")
                }
            }
        }
        .navigationTitle("Wi-Fi")
        .toolbar { if store.wifiEnabled { EditButton() } }
        .sheet(item: $joining) { JoinNetworkSheet(network: $0, engine: engine) }
        .task { engine.startScanning() }
        .onChange(of: store.wifiEnabled) { _, on in on ? engine.startScanning() : engine.stopScanning() }
        .onDisappear { engine.stopScanning() }
    }
}
