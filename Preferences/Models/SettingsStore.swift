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

    // MARK: Battery
    var lowPowerMode: Bool { didSet { UserDefaults.standard.set(lowPowerMode, forKey: "battery.lowPower") } }
    var adaptivePower: Bool { didSet { UserDefaults.standard.set(adaptivePower, forKey: "battery.adaptive") } }
    var batteryPercentage: Bool { didSet { UserDefaults.standard.set(batteryPercentage, forKey: "battery.percentage") } }
    var optimizedCharging: Bool { didSet { UserDefaults.standard.set(optimizedCharging, forKey: "battery.optimized") } }
    var chargeLimit: Int { didSet { UserDefaults.standard.set(chargeLimit, forKey: "battery.chargeLimit") } }

    // MARK: Hidden apps
    var hiddenAppBundleIDs: Set<String> { didSet { persist(Array(hiddenAppBundleIDs), key: "apps.hidden") } }
    var requireAuthForHiddenApps: Bool { didSet { UserDefaults.standard.set(requireAuthForHiddenApps, forKey: "apps.hidden.auth") } }
    var mockPasscode: String { didSet { UserDefaults.standard.set(mockPasscode, forKey: "mock.passcode") } }

    private init() {
        let d = UserDefaults.standard
        account = SettingsStore.load(MockAppleAccount.self, key: "account")
        wifiEnabled = d.object(forKey: "wifi.enabled") as? Bool ?? true
        knownNetworkSSIDs = Set(SettingsStore.load([String].self, key: "wifi.known") ?? ["Home-5G"])
        connectedSSID = d.object(forKey: "wifi.connected") == nil ? "Home-5G" : d.string(forKey: "wifi.connected")
        lowPowerMode = d.bool(forKey: "battery.lowPower")
        adaptivePower = d.bool(forKey: "battery.adaptive")
        batteryPercentage = d.object(forKey: "battery.percentage") as? Bool ?? true
        optimizedCharging = d.object(forKey: "battery.optimized") as? Bool ?? true
        chargeLimit = d.object(forKey: "battery.chargeLimit") as? Int ?? 80
        hiddenAppBundleIDs = Set(SettingsStore.load([String].self, key: "apps.hidden") ?? ["com.mock.ledger", "com.mock.notesplus"])
        requireAuthForHiddenApps = d.object(forKey: "apps.hidden.auth") as? Bool ?? true
        mockPasscode = d.string(forKey: "mock.passcode") ?? "000000"
    }

    private func persist<T: Encodable>(_ value: T?, key: String) {
        UserDefaults.standard.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: key)
    }
    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }
}
