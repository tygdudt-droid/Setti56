import SwiftUI
import Observation

struct MockWiFiNetwork: Identifiable, Hashable, Codable {
    var id: String { ssid }
    var ssid: String
    let security: Security
    var signal: Int          // 1...3
    let isHotspot: Bool
    var weakSecurity: Bool
    var password: String = ""
    var ipAddress: String = ""
    var router: String = ""

    enum Security: String, Codable, CaseIterable {
        case none, wpa2, wpa3, enterprise
        var label: String {
            switch self {
            case .none: return "Unsecured Network"
            case .wpa2: return "WPA2"
            case .wpa3: return "WPA3"
            case .enterprise: return "WPA2 Enterprise"
            }
        }
        var isSecured: Bool { self != .none }
    }

    var isWeak: Bool { weakSecurity }

    init(ssid: String, security: Security = .wpa2, signal: Int = 2, isHotspot: Bool = false,
         weakSecurity: Bool? = nil, password: String = "", ipAddress: String = "", router: String = "") {
        self.ssid = ssid
        self.security = security
        self.signal = signal
        self.isHotspot = isHotspot
        self.weakSecurity = weakSecurity ?? (security == .wpa2)
        self.password = password
        self.ipAddress = ipAddress
        self.router = router
    }

    private enum CodingKeys: String, CodingKey {
        case ssid, security, signal, isHotspot, weakSecurity, password, ipAddress, router
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ssid = try c.decode(String.self, forKey: .ssid)
        security = try c.decode(Security.self, forKey: .security)
        signal = try c.decode(Int.self, forKey: .signal)
        isHotspot = try c.decode(Bool.self, forKey: .isHotspot)
        weakSecurity = try c.decodeIfPresent(Bool.self, forKey: .weakSecurity) ?? (security == .wpa2)
        password = try c.decodeIfPresent(String.self, forKey: .password) ?? ""
        ipAddress = try c.decodeIfPresent(String.self, forKey: .ipAddress) ?? ""
        router = try c.decodeIfPresent(String.self, forKey: .router) ?? ""
    }
}

@MainActor
@Observable
final class WiFiEngine {
    private(set) var visible: [MockWiFiNetwork] = []
    private(set) var scanning = false
    private var scanTask: Task<Void, Never>?
    let store = SettingsStore.shared

    /// Default network pool, also used as the reset seed.
    static let pool: [MockWiFiNetwork] = [
        MockWiFiNetwork(ssid: "Home-5G", security: .wpa2, signal: 3, isHotspot: false),
        MockWiFiNetwork(ssid: "Home", security: .wpa2, signal: 3, isHotspot: false),
        MockWiFiNetwork(ssid: "xfinitywifi", security: .none, signal: 2, isHotspot: false),
        MockWiFiNetwork(ssid: "Starbucks WiFi", security: .none, signal: 1, isHotspot: false),
        MockWiFiNetwork(ssid: "NETGEAR47", security: .wpa2, signal: 2, isHotspot: false),
        MockWiFiNetwork(ssid: "Chris’s iPhone", security: .wpa2, signal: 3, isHotspot: true),
        MockWiFiNetwork(ssid: "eduroam", security: .enterprise, signal: 1, isHotspot: false),
        MockWiFiNetwork(ssid: "TP-Link_A1F0", security: .wpa2, signal: 1, isHotspot: false),
        MockWiFiNetwork(ssid: "Cafe Guest", security: .none, signal: 2, isHotspot: false)
    ]

    static func network(for ssid: String?) -> MockWiFiNetwork? {
        guard let ssid else { return nil }
        return SettingsStore.shared.wifiNetworks.first { $0.ssid == ssid }
    }

    func startScanning() {
        guard store.wifiEnabled else { visible = []; return }
        scanTask?.cancel()
        scanTask = Task { [weak self] in
            guard let self else { return }
            scanning = true
            visible = store.wifiNetworks.filter { store.knownNetworkSSIDs.contains($0.ssid) }
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            withAnimation(.smooth) { visible = store.wifiNetworks }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(6))
                guard !Task.isCancelled else { break }
                withAnimation {
                    visible = visible.map { n in
                        var c = n
                        c.signal = max(1, min(3, n.signal + Int.random(in: -1...1)))
                        return c
                    }
                }
            }
        }
    }

    func stopScanning() {
        scanTask?.cancel()
        scanTask = nil
        scanning = false
        visible = []
    }

    enum JoinError: LocalizedError {
        case incorrectPassword
        var errorDescription: String? { "Incorrect password" }
    }

    func join(_ network: MockWiFiNetwork, password: String?) async throws {
        if network.security.isSecured, (password ?? "").count < 8 {
            try? await Task.sleep(for: .seconds(0.8))
            throw JoinError.incorrectPassword
        }
        try? await Task.sleep(for: .seconds(1.5))
        store.knownNetworkSSIDs.insert(network.ssid)
        store.connectedSSID = network.ssid
    }

    func disconnect() { store.connectedSSID = nil }

    func forget(_ ssid: String) {
        store.knownNetworkSSIDs.remove(ssid)
        if store.connectedSSID == ssid { store.connectedSSID = nil }
    }
}
