import SwiftUI
import Observation

/// Single persisted store shared by Apple Account, Wi-Fi, Battery and Hidden Apps.
@MainActor
@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    // MARK: Apple Account
    var account: MockAppleAccount? { didSet { persist(account, key: "account") } }

    // MARK: Wi-Fi
    var wifiEnabled: Bool { didSet { UserDefaults.standard.set(wifiEnabled, forKey: "wifi.enabled") } }
    var knownNetworkSSIDs: Set<String> { didSet { persist(Array(knownNetworkSSIDs), key: "wifi.known") } }
    var connectedSSID: String? { didSet { UserDefaults.standard.set(connectedSSID, forKey: "wifi.connected") } }
    var wifiNetworks: [MockWiFiNetwork] { didSet { persist(wifiNetworks, key: "wifi.networks") } }

    // MARK: Battery
    var lowPowerMode: Bool { didSet { UserDefaults.standard.set(lowPowerMode, forKey: "battery.lowPower") } }
    var adaptivePower: Bool { didSet { UserDefaults.standard.set(adaptivePower, forKey: "battery.adaptive") } }
    var batteryPercentage: Bool { didSet { UserDefaults.standard.set(batteryPercentage, forKey: "battery.percentage") } }
    var optimizedCharging: Bool { didSet { UserDefaults.standard.set(optimizedCharging, forKey: "battery.optimized") } }
    var chargeLimit: Int { didSet { UserDefaults.standard.set(chargeLimit, forKey: "battery.chargeLimit") } }

    // MARK: Hidden apps
    /// Empty by default (like a real device). Key bumped so installs that
    /// still carry the old seeded set start clean.
    var hiddenAppBundleIDs: Set<String> { didSet { persist(Array(hiddenAppBundleIDs), key: "apps.hidden.v2") } }
    var requireAuthForHiddenApps: Bool { didSet { UserDefaults.standard.set(requireAuthForHiddenApps, forKey: "apps.hidden.auth") } }
    var mockPasscode: String { didSet { UserDefaults.standard.set(mockPasscode, forKey: "mock.passcode") } }

    // MARK: Storage (General > [Device] Storage)
    var storage: MockStorageSettings { didSet { persist(storage, key: "mock.storage") } }

    private init() {
        let d = UserDefaults.standard
        account = SettingsStore.load(MockAppleAccount.self, key: "account")
        wifiEnabled = d.object(forKey: "wifi.enabled") as? Bool ?? true
        knownNetworkSSIDs = Set(SettingsStore.load([String].self, key: "wifi.known") ?? ["Home-5G"])
        connectedSSID = d.object(forKey: "wifi.connected") == nil ? "Home-5G" : d.string(forKey: "wifi.connected")
        wifiNetworks = SettingsStore.load([MockWiFiNetwork].self, key: "wifi.networks") ?? WiFiEngine.pool
        lowPowerMode = d.bool(forKey: "battery.lowPower")
        adaptivePower = d.bool(forKey: "battery.adaptive")
        batteryPercentage = d.object(forKey: "battery.percentage") as? Bool ?? true
        optimizedCharging = d.object(forKey: "battery.optimized") as? Bool ?? true
        chargeLimit = d.object(forKey: "battery.chargeLimit") as? Int ?? 80
        hiddenAppBundleIDs = Set(SettingsStore.load([String].self, key: "apps.hidden.v2") ?? [])
        requireAuthForHiddenApps = d.object(forKey: "apps.hidden.auth") as? Bool ?? true
        mockPasscode = d.string(forKey: "mock.passcode") ?? "000000"
        storage = SettingsStore.load(MockStorageSettings.self, key: "mock.storage") ?? MockStorageSettings()
    }

    private func persist<T: Encodable>(_ value: T?, key: String) {
        UserDefaults.standard.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: key)
    }
    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    /// Restores the default network pool (Mock Configuration → Reset Wi-Fi Networks).
    func resetWiFi() {
        wifiNetworks = WiFiEngine.pool
        knownNetworkSSIDs = ["Home-5G"]
        connectedSSID = "Home-5G"
    }
}
