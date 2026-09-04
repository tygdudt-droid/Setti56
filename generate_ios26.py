#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_ios26.py
Generates the iOS 26 realism files for zhrispineda/Settings-iOS and places them
inside the app target folder. Existing files with the same name are moved to
_ios26_backup/ so the project keeps compiling.
"""
import argparse
import os
import plistlib
import re
import shutil
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# FILE CONTENTS
# ---------------------------------------------------------------------------
FILES = {}

# ============================ MODELS =======================================

FILES["Models/SeededGenerator.swift"] = r'''import Foundation

/// SplitMix64 – deterministic RNG so mock numbers do not change every launch.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

extension Date {
    static func daysAgo(_ d: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
    }
}

/// "3h 42m" / "45m" / "2h"
func minutesLabel(_ m: Int) -> String {
    if m >= 60 { return m % 60 == 0 ? "\(m / 60)h" : "\(m / 60)h \(m % 60)m" }
    return "\(m)m"
}
'''

FILES["Models/MockDevice.swift"] = r'''import UIKit

/// Crash-free device information (public API only).
struct MockDevice {
    static let current = MockDevice()

    let identifier: String = {
        if let sim = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] { return sim }
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: max(size, 1))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }()

    var isSimulator: Bool { ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] != nil }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var isPhone: Bool { !isPad }
    var deviceTypeName: String { isPad ? "iPad" : "iPhone" }

    /// Never traps – unknown identifiers fall back to UIDevice.model.
    var modelName: String { MockDevice.knownModels[identifier] ?? UIDevice.current.model }
    var systemName: String { UIDevice.current.systemName }
    var systemVersion: String { UIDevice.current.systemVersion }
    var buildNumber: String { "23A340" }
    var deviceName: String { UIDevice.current.name }

    /// Adaptive Power exists on iPhone 15 Pro and newer (not 16e).
    var supportsAdaptivePower: Bool {
        identifier.hasPrefix("iPhone16,") ||
        (identifier.hasPrefix("iPhone17,") && identifier != "iPhone17,5") ||
        identifier.hasPrefix("iPhone18,")
    }

    static let knownModels: [String: String] = [
        "iPhone14,7": "iPhone 14", "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro", "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15", "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro", "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro", "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16", "iPhone17,4": "iPhone 16 Plus", "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17 Pro", "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17", "iPhone18,4": "iPhone Air",
        "iPad14,3": "iPad Pro 11-inch (4th generation)", "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
        "iPad16,3": "iPad Pro 11-inch (M4)", "iPad16,5": "iPad Pro 13-inch (M4)",
        "iPad14,8": "iPad Air 11-inch (M2)", "iPad14,10": "iPad Air 13-inch (M2)",
        "iPad15,3": "iPad Air 11-inch (M3)", "iPad15,5": "iPad Air 13-inch (M3)",
        "iPad15,7": "iPad (A16)", "iPad16,1": "iPad mini (A17 Pro)"
    ]
}
'''

FILES["Models/MockDeviceIdentity.swift"] = r'''import Foundation

/// Deterministic per-install fake identifiers (serial, IMEI, MAC…).
struct MockDeviceIdentity: Codable {
    var serialNumber: String
    var imei: String
    var imei2: String
    var eid: String
    var seid: String
    var wifiAddress: String
    var bluetoothAddress: String
    var modemFirmware: String
    var modelNumber: String
    var regulatoryModel: String
    var iccid: String

    static var stored: MockDeviceIdentity {
        if let data = UserDefaults.standard.data(forKey: "mock.identity"),
           let id = try? JSONDecoder().decode(MockDeviceIdentity.self, from: data) { return id }
        let id = generate()
        UserDefaults.standard.set(try? JSONEncoder().encode(id), forKey: "mock.identity")
        return id
    }

    private static func generate() -> MockDeviceIdentity {
        let hexChars = Array("0123456789ABCDEF")
        let alnum = Array("ABCDEFGHJKLMNPQRSTUVWXYZ0123456789")
        let letters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")
        func hex(_ n: Int) -> String { String((0..<n).map { _ in hexChars.randomElement()! }) }
        func digits(_ n: Int) -> String { (0..<n).map { _ in String(Int.random(in: 0...9)) }.joined() }
        func mac() -> String { (0..<6).map { _ in hex(2) }.joined(separator: ":") }
        return MockDeviceIdentity(
            serialNumber: String((0..<10).map { _ in alnum.randomElement()! }),
            imei: "35 " + digits(6) + " " + digits(6) + " " + digits(1),
            imei2: "35 " + digits(6) + " " + digits(6) + " " + digits(1),
            eid: digits(32),
            seid: hex(40),
            wifiAddress: mac(),
            bluetoothAddress: mac(),
            modemFirmware: "1.\(Int.random(in: 0...3))0.0\(Int.random(in: 1...9))",
            modelNumber: "M" + String(letters.randomElement()!) + String(letters.randomElement()!) + digits(2) + "LL/A",
            regulatoryModel: "A\(Int.random(in: 3200...3399))",
            iccid: "8901" + digits(16))
    }
}
'''

FILES["Models/SettingsStore.swift"] = r'''import SwiftUI
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
'''

FILES["Models/MockAppleAccount.swift"] = r'''import Foundation

struct MockAppleAccount: Codable, Equatable {
    var email: String
    var firstName: String
    var lastName: String
    var avatarData: Data?
    var signedInAt: Date

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { String(firstName.prefix(1) + lastName.prefix(1)).uppercased() }

    /// Derive a plausible name from whatever the user typed.
    static func from(email: String) -> MockAppleAccount {
        let local = email.split(separator: "@").first.map(String.init) ?? "Apple User"
        let parts = local.split(whereSeparator: { ".-_".contains($0) }).map { $0.capitalized }
        return MockAppleAccount(email: email,
                                firstName: parts.first ?? "Apple",
                                lastName: parts.dropFirst().first ?? "User",
                                avatarData: nil,
                                signedInAt: .now)
    }
}
'''

FILES["Models/WiFiModels.swift"] = r'''import SwiftUI
import Observation

struct MockWiFiNetwork: Identifiable, Hashable, Codable {
    var id: String { ssid }
    let ssid: String
    let security: Security
    var signal: Int          // 1...3
    let isHotspot: Bool

    enum Security: String, Codable {
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
}

@MainActor
@Observable
final class WiFiEngine {
    private(set) var visible: [MockWiFiNetwork] = []
    private(set) var scanning = false
    private var scanTask: Task<Void, Never>?
    let store = SettingsStore.shared

    static let pool: [MockWiFiNetwork] = [
        MockWiFiNetwork(ssid: "Home-5G", security: .wpa3, signal: 3, isHotspot: false),
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
        return pool.first { $0.ssid == ssid }
    }

    func startScanning() {
        guard store.wifiEnabled else { visible = []; return }
        scanTask?.cancel()
        scanTask = Task { [weak self] in
            guard let self else { return }
            scanning = true
            visible = Self.pool.filter { store.knownNetworkSSIDs.contains($0.ssid) }
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            withAnimation(.smooth) { visible = Self.pool }
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
'''

FILES["Models/MockAppCatalog.swift"] = r'''import SwiftUI

enum AppLibraryCategory: String, CaseIterable, Codable {
    case suggestions = "Suggestions"
    case recentlyAdded = "Recently Added"
    case social = "Social"
    case entertainment = "Entertainment"
    case creativity = "Creativity"
    case productivity = "Productivity & Finance"
    case utilities = "Utilities"
    case information = "Information & Reading"
    case games = "Games"
    case travel = "Travel"
    case healthFitness = "Health & Fitness"
    case other = "Other"
}

struct MockApp: Identifiable, Hashable, Codable {
    var id: String { bundleID }
    let bundleID: String
    let name: String
    let icon: String        // SF Symbol
    let tintHex: String
    let category: AppLibraryCategory
    let installedAt: Date
    var tint: Color { Color.fromHex(tintHex) }
}

extension Color {
    static func fromHex(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        return Color(red: Double((v >> 16) & 0xFF) / 255,
                     green: Double((v >> 8) & 0xFF) / 255,
                     blue: Double(v & 0xFF) / 255)
    }
}

enum MockAppCatalog {
    static let all: [MockApp] = [
        MockApp(bundleID: "com.mock.chirp", name: "Chirp", icon: "bird.fill", tintHex: "1D9BF0", category: .social, installedAt: .daysAgo(40)),
        MockApp(bundleID: "com.mock.mosaic", name: "Mosaic", icon: "square.grid.3x3.fill", tintHex: "E1306C", category: .social, installedAt: .daysAgo(3)),
        MockApp(bundleID: "com.mock.pingme", name: "PingMe", icon: "bubble.left.and.bubble.right.fill", tintHex: "25D366", category: .social, installedAt: .daysAgo(90)),
        MockApp(bundleID: "com.mock.streamr", name: "Streamr", icon: "play.rectangle.fill", tintHex: "E50914", category: .entertainment, installedAt: .daysAgo(80)),
        MockApp(bundleID: "com.mock.tunes", name: "Tunes", icon: "music.note", tintHex: "FC3C44", category: .entertainment, installedAt: .daysAgo(200)),
        MockApp(bundleID: "com.mock.sketchpad", name: "Sketchpad", icon: "pencil.and.outline", tintHex: "8E44AD", category: .creativity, installedAt: .daysAgo(12)),
        MockApp(bundleID: "com.mock.lens", name: "Lens", icon: "camera.aperture", tintHex: "5856D6", category: .creativity, installedAt: .daysAgo(9)),
        MockApp(bundleID: "com.mock.ledger", name: "Ledger", icon: "dollarsign.circle.fill", tintHex: "34C759", category: .productivity, installedAt: .daysAgo(60)),
        MockApp(bundleID: "com.mock.taskr", name: "Taskr", icon: "checklist", tintHex: "FFCC00", category: .productivity, installedAt: .daysAgo(1)),
        MockApp(bundleID: "com.mock.notesplus", name: "Notes+", icon: "note.text", tintHex: "FF9500", category: .productivity, installedAt: .daysAgo(30)),
        MockApp(bundleID: "com.mock.scanit", name: "ScanIt", icon: "doc.viewfinder", tintHex: "8E8E93", category: .utilities, installedAt: .daysAgo(120)),
        MockApp(bundleID: "com.mock.speed", name: "Speed", icon: "gauge.with.dots.needle.67percent", tintHex: "32ADE6", category: .utilities, installedAt: .daysAgo(15)),
        MockApp(bundleID: "com.mock.vault", name: "Vault", icon: "lock.shield.fill", tintHex: "1C1C1E", category: .utilities, installedAt: .daysAgo(300)),
        MockApp(bundleID: "com.mock.daily", name: "Daily", icon: "newspaper.fill", tintHex: "D70015", category: .information, installedAt: .daysAgo(70)),
        MockApp(bundleID: "com.mock.reader", name: "Reader", icon: "book.fill", tintHex: "A2845E", category: .information, installedAt: .daysAgo(2)),
        MockApp(bundleID: "com.mock.orbit", name: "Orbit", icon: "gamecontroller.fill", tintHex: "00C7BE", category: .games, installedAt: .daysAgo(5)),
        MockApp(bundleID: "com.mock.puzzlr", name: "Puzzlr", icon: "puzzlepiece.fill", tintHex: "30B0C7", category: .games, installedAt: .daysAgo(25)),
        MockApp(bundleID: "com.mock.wander", name: "Wander", icon: "map.fill", tintHex: "2E8B57", category: .travel, installedAt: .daysAgo(45)),
        MockApp(bundleID: "com.mock.pulse", name: "Pulse", icon: "heart.fill", tintHex: "FF2D55", category: .healthFitness, installedAt: .daysAgo(18)),
        MockApp(bundleID: "com.mock.flightly", name: "Flightly", icon: "airplane", tintHex: "007AFF", category: .travel, installedAt: .daysAgo(7))
    ]

    static func app(_ bundleID: String) -> MockApp? { all.first { $0.bundleID == bundleID } }

    static var recentlyAdded: [MockApp] { Array(all.sorted { $0.installedAt > $1.installedAt }.prefix(4)) }

    static var suggestions: [MockApp] {
        var rng = SeededGenerator(seed: 7)
        return Array(all.shuffled(using: &rng).prefix(4))
    }

    static func apps(in category: AppLibraryCategory, excluding hidden: Set<String>) -> [MockApp] {
        switch category {
        case .suggestions: return suggestions.filter { !hidden.contains($0.bundleID) }
        case .recentlyAdded: return recentlyAdded.filter { !hidden.contains($0.bundleID) }
        default: return all.filter { $0.category == category && !hidden.contains($0.bundleID) }
        }
    }
}
'''

FILES["Models/BatteryDataProvider.swift"] = r'''import SwiftUI
import Observation

struct BatterySample: Identifiable, Codable {
    let id: UUID
    let date: Date
    let level: Double   // 0...1
    let charging: Bool
    let lowPower: Bool
    let screenOn: Bool
}

struct AppBatteryUsage: Identifiable {
    var id: String { app.bundleID }
    let app: MockApp
    let screenOnMinutes: Int
    let backgroundMinutes: Int
    var energyShare: Double
}

struct BatteryDay: Identifiable {
    var id: Date { date }
    let date: Date
    let percentUsed: Int
    let screenOnMinutes: Int
    let screenOffMinutes: Int
    let apps: [AppBatteryUsage]
}

@MainActor
@Observable
final class BatteryDataProvider {
    static let shared = BatteryDataProvider()

    let last24h: [BatterySample]
    let last10d: [BatteryDay]
    let todayApps: [AppBatteryUsage]
    let lastChargedTo = 100
    let lastChargedAt: Date
    let maximumCapacity = 96
    let cycleCount = 187

    var currentLevel: Int { Int((last24h.last?.level ?? 0.8) * 100) }
    var screenOnMinutesToday: Int { last24h.filter(\.screenOn).count * 15 / 2 }
    var screenOffMinutesToday: Int { last24h.filter { !$0.screenOn }.count * 15 / 2 }
    var todayUsagePercent: Int { 100 - currentLevel }
    var dailyAveragePercent: Int { last10d.dropLast().map(\.percentUsed).reduce(0, +) / max(1, last10d.count - 1) }

    init() {
        var rng = SeededGenerator(seed: 26)
        let now = Date.now
        let cal = Calendar.current
        let charged = cal.date(bySettingHour: 7, minute: 32, second: 0, of: now) ?? now
        lastChargedAt = charged > now ? charged.addingTimeInterval(-86_400) : charged

        var samples: [BatterySample] = []
        for i in 0..<96 {
            let t = now.addingTimeInterval(TimeInterval(-15 * 60 * (95 - i)))
            let hoursSinceCharge = t.timeIntervalSince(lastChargedAt) / 3600
            let charging = hoursSinceCharge < 0 && hoursSinceCharge > -2.5
            let level: Double
            if charging {
                level = min(1, 0.55 + (2.5 + hoursSinceCharge) * 0.18)
            } else if hoursSinceCharge < 0 {
                level = max(0.15, 0.95 - (-hoursSinceCharge - 2.5) * 0.04)
            } else {
                level = max(0.12, 1 - hoursSinceCharge * 0.045 + Double.random(in: -0.008...0.008, using: &rng))
            }
            let hour = cal.component(.hour, from: t)
            let screenOn = (hour >= 8 && hour <= 23) && Bool.random(using: &rng)
            samples.append(BatterySample(id: UUID(), date: t, level: level, charging: charging, lowPower: level < 0.2, screenOn: screenOn))
        }
        last24h = samples

        func makeApps(_ rng: inout SeededGenerator) -> [AppBatteryUsage] {
            var apps = MockAppCatalog.all.shuffled(using: &rng).prefix(8).map {
                AppBatteryUsage(app: $0,
                                screenOnMinutes: Int.random(in: 4...95, using: &rng),
                                backgroundMinutes: Int.random(in: 0...30, using: &rng),
                                energyShare: 0)
            }
            let total = Double(apps.map { $0.screenOnMinutes + $0.backgroundMinutes }.reduce(0, +))
            for i in apps.indices {
                apps[i].energyShare = Double(apps[i].screenOnMinutes + apps[i].backgroundMinutes) / max(1, total)
            }
            return apps.sorted { $0.energyShare > $1.energyShare }
        }

        var days: [BatteryDay] = []
        for d in (0..<10).reversed() {
            let date = cal.startOfDay(for: cal.date(byAdding: .day, value: -d, to: now) ?? now)
            days.append(BatteryDay(date: date,
                                   percentUsed: Int.random(in: 45...130, using: &rng),
                                   screenOnMinutesToday(&rng),
                                   screenOffMinutes: Int.random(in: 60...420, using: &rng),
                                   apps: makeApps(&rng)))
        }
        last10d = days
        todayApps = days.last?.apps ?? []
    }
}

private extension BatteryDay {
    init(date: Date, percentUsed: Int, _ screenOn: Int, screenOffMinutes: Int, apps: [AppBatteryUsage]) {
        self.init(date: date, percentUsed: percentUsed, screenOnMinutes: screenOn, screenOffMinutes: screenOffMinutes, apps: apps)
    }
}
private func screenOnMinutesToday(_ rng: inout SeededGenerator) -> Int { Int.random(in: 120...420, using: &rng) }

extension Array where Element == BatterySample {
    func nearest(to date: Date) -> BatterySample? {
        self.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }
}
'''

FILES["Models/ScreenTimeProvider.swift"] = r'''import SwiftUI
import Charts
import Observation

enum ScreenTimeCategory: String, CaseIterable, Codable, Plottable {
    case social = "Social"
    case entertainment = "Entertainment"
    case productivity = "Productivity & Finance"
    case creativity = "Creativity"
    case games = "Games"
    case information = "Information & Reading"
    case other = "Other"

    var color: Color {
        switch self {
        case .social: return .blue
        case .entertainment: return .teal
        case .productivity: return Color(red: 0.42, green: 0.45, blue: 0.68)
        case .creativity: return .orange
        case .games: return .purple
        case .information: return .mint
        case .other: return .gray
        }
    }
    var weight: Double {
        switch self {
        case .social: return 1.0
        case .entertainment: return 0.8
        case .productivity: return 0.6
        case .creativity: return 0.3
        case .games: return 0.4
        case .information: return 0.4
        case .other: return 0.3
        }
    }
}

struct AppUsage: Identifiable {
    var id: String { app.bundleID }
    let app: MockApp
    let minutes: Int
}

struct ScreenTimeDay: Identifiable {
    var id: Date { date }
    let date: Date
    let hourly: [[ScreenTimeCategory: Int]]   // 24 buckets
    let pickups: Int
    let notifications: Int
    let mostUsed: [AppUsage]

    var byCategory: [ScreenTimeCategory: Int] {
        hourly.reduce(into: [:]) { acc, b in for (k, v) in b { acc[k, default: 0] += v } }
    }
    var total: Int { byCategory.values.reduce(0, +) }
    var topCategories: [ScreenTimeCategory] {
        byCategory.sorted { $0.value > $1.value }.prefix(3).map(\.key)
    }
}

@MainActor
@Observable
final class ScreenTimeProvider {
    static let shared = ScreenTimeProvider()

    let week: [ScreenTimeDay]
    let lastWeekAverage = 231

    var today: ScreenTimeDay { week.last! }
    var dailyAverage: Int { week.map(\.total).reduce(0, +) / max(1, week.count) }
    var deltaPercent: Int { Int((Double(dailyAverage - lastWeekAverage) / Double(lastWeekAverage)) * 100) }
    var weekTopCategories: [ScreenTimeCategory] {
        var totals: [ScreenTimeCategory: Int] = [:]
        for d in week { for (k, v) in d.byCategory { totals[k, default: 0] += v } }
        return totals.sorted { $0.value > $1.value }.prefix(3).map(\.key)
    }
    func day(for date: Date?) -> ScreenTimeDay? {
        guard let date else { return nil }
        return week.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    init() {
        var rng = SeededGenerator(seed: 2026)
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        week = (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            var hourly: [[ScreenTimeCategory: Int]] = []
            for h in 0..<24 {
                var bucket: [ScreenTimeCategory: Int] = [:]
                let active: Double = (h >= 7 && h <= 23) ? 1 : 0.05
                for cat in ScreenTimeCategory.allCases {
                    let m = Int(Double.random(in: 0...(cat.weight * 8 * active), using: &rng))
                    if m > 0 { bucket[cat] = m }
                }
                hourly.append(bucket)
            }
            let apps = MockAppCatalog.all.shuffled(using: &rng).prefix(6)
                .map { AppUsage(app: $0, minutes: Int.random(in: 8...80, using: &rng)) }
                .sorted { $0.minutes > $1.minutes }
            return ScreenTimeDay(date: date, hourly: hourly,
                                 pickups: Int.random(in: 40...120, using: &rng),
                                 notifications: Int.random(in: 60...220, using: &rng),
                                 mostUsed: apps)
        }
    }
}
'''

FILES["Models/AnalyticsStore.swift"] = r'''import Foundation
import Observation

struct AnalyticsFile: Identifiable, Hashable {
    let url: URL
    var id: URL { url }
    var name: String { url.lastPathComponent }
}

/// Real files on disk (Application Support/DiagnosticReports) so ShareLink works.
@Observable
final class AnalyticsStore {
    static let shared = AnalyticsStore()
    private(set) var files: [AnalyticsFile] = []

    let directory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appending(path: "DiagnosticReports", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        seedIfNeeded()
        reload()
    }

    func reload() {
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        files = urls.map(AnalyticsFile.init)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func contents(of file: AnalyticsFile) -> String {
        (try? String(contentsOf: file.url, encoding: .utf8)) ?? ""
    }

    func deleteAll() {
        for f in files { try? FileManager.default.removeItem(at: f.url) }
        reload()
    }

    /// ~40 files over the last 7 days on first launch, then a few new ones per launch.
    private func seedIfNeeded() {
        let existing = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        let days = existing.isEmpty ? 7 : 1
        for d in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
            write(AnalyticsFileTemplates.analytics(date: date))
            write(AnalyticsFileTemplates.logAggregated(date: date))
            if d % 2 == 0 { write(AnalyticsFileTemplates.jetsam(date: date)) }
            if d % 3 == 0 { write(AnalyticsFileTemplates.wifiLQM(date: date)) }
            if d == 0 && existing.isEmpty {
                write(AnalyticsFileTemplates.stacks(date: date))
                write(AnalyticsFileTemplates.awdd(date: date))
                write(AnalyticsFileTemplates.logPower(date: date))
            }
        }
    }

    private func write(_ f: (name: String, body: String)) {
        let url = directory.appending(path: f.name)
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        try? f.body.write(to: url, atomically: true, encoding: .utf8)
    }
}
'''

FILES["Models/AnalyticsFileTemplates.swift"] = r'''import Foundation

enum AnalyticsFileTemplates {
    private static let stamp: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd-HHmmss"
        return f
    }()
    private static let iso = ISO8601DateFormatter()
    private static let osVersion = "iPhone OS 26.0 (23A340)"

    private static func header(_ date: Date, bugType: String = "211", extra: String = "") -> String {
        "{\"bug_type\":\"\(bugType)\",\"timestamp\":\"\(iso.string(from: date))\",\"os_version\":\"\(osVersion)\",\"roots_installed\":0,\"incident_id\":\"\(UUID().uuidString)\"\(extra)}"
    }

    static func analytics(date: Date) -> (name: String, body: String) {
        let names = ["com.apple.power.battery.log", "com.apple.Preferences.usage", "com.apple.springboard.launch",
                     "com.apple.wifi.assoc", "com.apple.cellular.datausage", "com.apple.thermal.state"]
        let events = ["PowerlogEvent", "AppLaunch", "WiFiAssociation", "ThermalLevel", "CellularUsage"]
        let body = (0..<40).map { _ -> String in
            let t = date.addingTimeInterval(-Double.random(in: 0...86_400))
            return "{\"message\":{\"name\":\"\(names.randomElement()!)\",\"summarizationCount\":\(Int.random(in: 1...900)),\"sampleCount\":\(Int.random(in: 1...60))},\"name\":\"\(events.randomElement()!)\",\"uuid\":\"\(UUID().uuidString)\",\"timestamp\":\"\(iso.string(from: t))\"}"
        }.joined(separator: "\n")
        return ("Analytics-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }

    static func logAggregated(date: Date) -> (name: String, body: String) {
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        \t<key>osVersion</key>
        \t<string>\(osVersion)</string>
        \t<key>scalars</key>
        \t<dict>
        \t\t<key>com.apple.power.batteryDrainRate</key>
        \t\t<integer>\(Int.random(in: 3...9))</integer>
        \t\t<key>com.apple.springboard.homeScreenTime</key>
        \t\t<integer>\(Int.random(in: 900...12_000))</integer>
        \t\t<key>com.apple.wifi.numberOfAssociations</key>
        \t\t<integer>\(Int.random(in: 2...40))</integer>
        \t\t<key>com.apple.backboardd.displayOnTime</key>
        \t\t<integer>\(Int.random(in: 5_000...30_000))</integer>
        \t</dict>
        </dict>
        </plist>
        """
        return ("log-aggregated-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "211") + "\n" + plist)
    }

    static func jetsam(date: Date) -> (name: String, body: String) {
        let procs = ["MobileSafari", "SpringBoard", "mediaserverd", "Preferences", "backboardd", "photoanalysisd"]
        let body = """
        {
          "reason" : "per-process-limit",
          "largestProcess" : "\(procs.randomElement()!)",
          "memoryStatus" : { "pageSize" : 16384, "memoryPages" : { "active" : \(Int.random(in: 60_000...90_000)), "free" : \(Int.random(in: 4_000...9_000)), "wired" : \(Int.random(in: 30_000...45_000)) } },
          "processes" : [
            { "name" : "SpringBoard", "pid" : 58, "rpages" : \(Int.random(in: 20_000...40_000)), "states" : ["frontmost", "resident"] },
            { "name" : "\(procs.randomElement()!)", "pid" : \(Int.random(in: 300...9_000)), "rpages" : \(Int.random(in: 40_000...90_000)), "states" : ["suspended"] , "killDelta" : 0 }
          ]
        }
        """
        return ("JetsamEvent-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "298") + "\n" + body)
    }

    static func wifiLQM(date: Date) -> (name: String, body: String) {
        let body = (0..<12).map { i -> String in
            "{\"t\":\"\(iso.string(from: date.addingTimeInterval(Double(i) * -3600)))\",\"rssi\":\(Int.random(in: -75 ... -40)),\"snr\":\(Int.random(in: 18...45)),\"txRate\":\(Int.random(in: 86...866)),\"channel\":\([1, 6, 11, 36, 44, 149].randomElement()!),\"lqm\":\(Int.random(in: 40...100))}"
        }.joined(separator: "\n")
        return ("WiFiLQMMetrics-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }

    static func stacks(date: Date) -> (name: String, body: String) {
        let body = """
        Date/Time:        \(date)
        OS Version:       \(osVersion)
        Reason:           periodic stackshot
        Trigger:          sysdiagnose

        Process:          SpringBoard [58]
        Thread 0x1a2b  DispatchQueue "com.apple.main-thread"
          0  libsystem_kernel.dylib  mach_msg2_trap + 8
          1  libsystem_kernel.dylib  mach_msg2_internal + 80
          2  CoreFoundation          __CFRunLoopServiceMachPort + 160
          3  CoreFoundation          __CFRunLoopRun + 1212
          4  CoreFoundation          CFRunLoopRunSpecific + 588
          5  GraphicsServices        GSEventRunModal + 164
          6  UIKitCore               -[UIApplication _run] + 816
          7  UIKitCore               UIApplicationMain + 340
        """
        return ("stacks-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "288") + "\n" + body)
    }

    static func awdd(date: Date) -> (name: String, body: String) {
        let body = (0..<30).map { _ in
            "\(Int.random(in: 100_000...999_999))\t\(["wifi", "cellular", "bluetooth", "location"].randomElement()!)\t\(Int.random(in: 0...1_000))"
        }.joined(separator: "\n")
        return ("awdd-\(stamp.string(from: date)).metriclog", body)
    }

    static func logPower(date: Date) -> (name: String, body: String) {
        let body = (0..<24).map { h in
            "\(iso.string(from: date.addingTimeInterval(Double(h) * -3600)))\tlevel=\(Int.random(in: 10...100))\tcharging=\(Bool.random())\tthermal=\(["nominal", "fair", "serious"].randomElement()!)"
        }.joined(separator: "\n")
        return ("log-power-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }
}
'''

FILES["Models/HiddenAppsAuth.swift"] = r'''import LocalAuthentication

enum HiddenAppsAuth {
    /// Returns true when Face ID / Touch ID / device passcode succeeded.
    /// Returns nil when biometrics are unavailable (caller shows the mock passcode sheet).
    static func authenticate(reason: String = "Unlock Hidden Apps") async -> Bool? {
        let ctx = LAContext()
        ctx.localizedFallbackTitle = "Enter Passcode"
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) else { return nil }
        do {
            return try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }
}
'''

# ============================ COMPONENTS ===================================

FILES["Components/GlassCompat.swift"] = r'''import SwiftUI

/// iOS 26 Liquid Glass with graceful fallback for older SDK/OS.
extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    @ViewBuilder
    func glassProminentButton() -> some View {
        if #available(iOS 26.0, *) { self.buttonStyle(.glassProminent) } else { self.buttonStyle(.borderedProminent) }
    }

    @ViewBuilder
    func glassButton() -> some View {
        if #available(iOS 26.0, *) { self.buttonStyle(.glass) } else { self.buttonStyle(.bordered) }
    }
}
'''

FILES["Components/AppIconView.swift"] = r'''import SwiftUI

/// Apple-style squircle icon (continuous corners, 22.37% radius).
struct AppIconView: View {
    let app: MockApp
    var side: CGFloat = 60

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: side * 0.2237, style: .continuous)
                .fill(LinearGradient(colors: [app.tint.opacity(0.82), app.tint],
                                     startPoint: .top, endPoint: .bottom))
            Image(systemName: app.icon)
                .font(.system(size: side * 0.46, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: side, height: side)
        .accessibilityLabel(app.name)
    }
}
'''

FILES["Components/ShakeEffect.swift"] = r'''import SwiftUI

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 6), y: 0))
    }
}
'''

FILES["Components/MockPasscodeSheet.swift"] = r'''import SwiftUI

/// Lock-screen style 6-digit passcode entry.
struct MockPasscodeSheet: View {
    var title = "Enter Passcode"
    var onResult: (Bool) -> Void

    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var entered = ""
    @State private var shake = 0

    private let keys: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)
            Image(systemName: "lock.fill").font(.title2).foregroundStyle(.secondary)
            Text(title).font(.title3.weight(.semibold))
            HStack(spacing: 18) {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .strokeBorder(.primary, lineWidth: 1.2)
                        .background(Circle().fill(i < entered.count ? Color.primary : .clear))
                        .frame(width: 13, height: 13)
                }
            }
            .modifier(ShakeEffect(shakes: shake))
            Spacer()
            VStack(spacing: 16) {
                ForEach(keys, id: \.self) { row in
                    HStack(spacing: 24) {
                        ForEach(row, id: \.self) { key in
                            Button { tap(key) } label: {
                                Text(key).font(.system(size: 30, weight: .regular))
                                    .frame(width: 78, height: 78)
                                    .background(Circle().fill(key.isEmpty ? .clear : Color.primary.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                            .disabled(key.isEmpty)
                        }
                    }
                }
            }
            Button("Cancel") { dismiss(); onResult(false) }
                .padding(.bottom, 24)
        }
        .padding()
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }

    private func tap(_ key: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if key == "⌫" { if !entered.isEmpty { entered.removeLast() }; return }
        guard entered.count < 6 else { return }
        entered.append(key)
        if entered.count == 6 {
            if entered == store.mockPasscode {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss(); onResult(true)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                withAnimation(.default) { shake += 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { entered = "" }
            }
        }
    }
}
'''

# ============================ ABOUT ========================================

FILES["Views/General/AboutView.swift"] = r'''import SwiftUI

/// iOS 26 "About" – public API only, cannot crash.
struct AboutView: View {
    @AppStorage("device.name") private var name = UIDevice.current.name
    @State private var showRegulatoryModel = false
    private let device = MockDevice.current
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        List {
            Section {
                NavigationLink { DeviceNameView(name: $name) } label: {
                    LabeledContent("Name", value: name)
                }
            }

            Section {
                NavigationLink { IOSVersionView() } label: {
                    LabeledContent("\(device.systemName) Version", value: device.systemVersion)
                }
                LabeledContent("Model Name", value: device.modelName)
                LabeledContent("Model Number", value: showRegulatoryModel ? identity.regulatoryModel : identity.modelNumber)
                    .contentShape(Rectangle())
                    .onTapGesture { showRegulatoryModel.toggle() }
                LabeledContent("Serial Number", value: identity.serialNumber)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.serialNumber } }
                NavigationLink { CoverageView() } label: {
                    LabeledContent("Coverage", value: "Limited Warranty")
                }
            }

            Section {
                LabeledContent("Songs", value: "0")
                LabeledContent("Videos", value: "12")
                LabeledContent("Photos", value: "3,482")
                LabeledContent("Applications", value: "\(MockAppCatalog.all.count)")
                LabeledContent("Capacity", value: "256 GB")
                LabeledContent("Available", value: "118.42 GB")
            }

            Section {
                LabeledContent("Wi-Fi Address", value: identity.wifiAddress)
                LabeledContent("Bluetooth", value: identity.bluetoothAddress)
                LabeledContent("Modem Firmware", value: identity.modemFirmware)
                LabeledContent("SEID", value: String(identity.seid.prefix(8)) + "…")
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.seid } }
                LabeledContent("EID", value: identity.eid)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.eid } }
                LabeledContent("Carrier Lock", value: "No SIM restrictions")
            }

            if device.isPhone {
                Section("Available SIMs") {
                    NavigationLink { SIMDetailView(identity: identity) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Primary")
                            Text("No SIM").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                NavigationLink("Certificate Trust Settings") { CertificateTrustView() }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeviceNameView: View {
    @Binding var name: String
    @FocusState private var focused: Bool
    var body: some View {
        List {
            HStack {
                TextField("Name", text: $name).focused($focused)
                if !name.isEmpty {
                    Button { name = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .buttonStyle(.borderless)
                }
            }
        }
        .navigationTitle("Name")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }
}

struct IOSVersionView: View {
    private let d = MockDevice.current
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(d.systemName) \(d.systemVersion)").font(.headline)
                    Text("Build \(d.buildNumber)").font(.footnote).foregroundStyle(.secondary)
                }
            } footer: {
                Text("\(d.systemName) \(d.systemVersion) brings a beautiful new design with Liquid Glass, more expressive experiences across your apps, and intelligent features that make everyday tasks easier.")
            }
        }
        .navigationTitle("\(d.systemName) Version")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CoverageView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Limited Warranty", value: "Active")
                LabeledContent("Expires", value: Date.now.addingTimeInterval(200 * 86_400).formatted(date: .abbreviated, time: .omitted))
            } footer: {
                Text("Your device is covered by Apple’s Limited Warranty for hardware repairs and service.")
            }
            Section {
                Link("Learn About AppleCare+", destination: URL(string: "https://www.apple.com/support/products/")!)
            }
        }
        .navigationTitle("Coverage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SIMDetailView: View {
    let identity: MockDeviceIdentity
    var body: some View {
        List {
            Section {
                LabeledContent("Network", value: "—")
                LabeledContent("Carrier", value: "—")
                LabeledContent("IMEI", value: identity.imei)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.imei } }
                LabeledContent("IMEI2", value: identity.imei2)
                LabeledContent("ICCID", value: identity.iccid)
            }
        }
        .navigationTitle("Primary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CertificateTrustView: View {
    @State private var fullTrust = false
    var body: some View {
        List {
            Section {
                LabeledContent("Trust Store Version", value: "2025071100")
                LabeledContent("Trust Asset Version", value: "80")
            }
            Section {
                Toggle("Enable Full Trust for Root Certificates", isOn: $fullTrust)
            } footer: {
                Text("No certificates have been installed on this device.")
            }
        }
        .navigationTitle("Certificate Trust Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

# ============================ APPLE ACCOUNT ================================

FILES["Views/Apple Account/AvatarView.swift"] = r'''import SwiftUI

struct AvatarView: View {
    let account: MockAppleAccount
    var size: CGFloat = 60

    var body: some View {
        Group {
            if let data = account.avatarData, let img = UIImage(data: data) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [Color(.systemGray2), Color(.systemGray4)], startPoint: .top, endPoint: .bottom)
                    Text(account.initials)
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
'''

FILES["Views/Apple Account/AppleAccountRow.swift"] = r'''import SwiftUI

/// Drop this at the very top of the root Settings list.
struct AppleAccountRow: View {
    @Environment(SettingsStore.self) private var store
    @State private var showSignIn = false

    var body: some View {
        if let account = store.account {
            NavigationLink { AppleAccountView() } label: {
                HStack(spacing: 14) {
                    AvatarView(account: account, size: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.fullName).font(.title2)
                        Text("Apple Account, iCloud, and more").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        } else {
            Button { showSignIn = true } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56)).foregroundStyle(.gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sign in to your \(MockDevice.current.deviceTypeName)")
                            .font(.title3).foregroundStyle(.primary)
                        Text("Set up iCloud, the App Store, and more.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.footnote.bold()).foregroundStyle(.tertiary)
                }
                .padding(.vertical, 6)
            }
            .sheet(isPresented: $showSignIn) { AppleAccountSignInSheet() }
        }
    }
}
'''

FILES["Views/Apple Account/AppleAccountSignInSheet.swift"] = r'''import SwiftUI

struct AppleAccountSignInSheet: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    enum Step { case email, password, verifying, code }
    @State private var step: Step = .email
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var error: String?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "apple.logo").font(.system(size: 44)).padding(.top, 20)
                VStack(spacing: 6) {
                    Text(step == .email ? "Sign in with an Apple Account" : email)
                        .font(step == .email ? .title2.bold() : .headline)
                        .multilineTextAlignment(.center)
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                Group {
                    switch step {
                    case .email:
                        TextField("Email or Phone Number", text: $email)
                            .textContentType(.username).keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                            .focused($focused)
                            .padding(14).glassCard(cornerRadius: 12)
                    case .password:
                        SecureField("Password", text: $password)
                            .textContentType(.password).focused($focused)
                            .padding(14).glassCard(cornerRadius: 12)
                    case .verifying:
                        ProgressView("Signing In…").padding()
                    case .code:
                        VerificationCodeField(code: $code)
                    }
                }
                .padding(.horizontal)
                if let error { Text(error).foregroundStyle(.red).font(.footnote) }
                Spacer()
                Button(action: advance) {
                    Text("Continue").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .glassProminentButton()
                .disabled(!canContinue)
                .padding(.horizontal)
                Button("Forgot password or don’t have an account?") {}.font(.footnote).padding(.bottom, 8)
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .onAppear { focused = true }
        }
        .interactiveDismissDisabled(step == .verifying)
    }

    private var subtitle: String {
        switch step {
        case .email: return "Your Apple Account is used to access iCloud, the App Store, and more."
        case .password: return "Enter the password for your Apple Account."
        case .verifying: return ""
        case .code: return "A message with a verification code has been sent to your devices. Enter the code to continue."
        }
    }

    private var canContinue: Bool {
        switch step {
        case .email: return email.contains("@") || email.filter(\.isNumber).count >= 10
        case .password: return password.count >= 4
        case .code: return code.count == 6
        case .verifying: return false
        }
    }

    private func advance() {
        error = nil
        switch step {
        case .email:
            withAnimation { step = .password }
            focused = true
        case .password:
            withAnimation { step = .verifying }
            Task {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation { step = .code }
            }
        case .code:
            store.account = .from(email: email)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        case .verifying:
            break
        }
    }
}

struct VerificationCodeField: View {
    @Binding var code: String
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad).textContentType(.oneTimeCode)
                .focused($focused).opacity(0.01)
                .onChange(of: code) { _, v in code = String(v.filter(\.isNumber).prefix(6)) }
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { i in
                    let chars = Array(code)
                    Text(i < chars.count ? String(chars[i]) : " ")
                        .font(.title2.monospacedDigit())
                        .frame(width: 42, height: 52)
                        .glassCard(cornerRadius: 10)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .frame(height: 52)
        .onAppear { focused = true }
    }
}
'''

FILES["Views/Apple Account/AppleAccountView.swift"] = r'''import SwiftUI
import PhotosUI

struct AppleAccountView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var confirmSignOut = false
    @State private var showKeepData = false

    var body: some View {
        if let account = store.account {
            List {
                Section {
                    VStack(spacing: 10) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                AvatarView(account: account, size: 110)
                                Text("EDIT").font(.caption2.bold())
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(.thinMaterial))
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .buttonStyle(.plain)
                        Text(account.fullName).font(.title2.weight(.semibold))
                        Text(account.email).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    row("Personal Information", "person.text.rectangle", .gray)
                    row("Sign-In & Security", "lock.shield", .gray)
                    row("Payment & Shipping", "creditcard", .gray)
                    row("Subscriptions", "arrow.triangle.2.circlepath", .gray)
                }

                Section {
                    row("iCloud", "icloud", .blue, value: "5 GB")
                    row("Family", "person.2", .blue)
                    row("Media & Purchases", "appstore", .blue)
                    row("Sign in with Apple", "apple.logo", .black)
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: MockDevice.current.isPad ? "ipad" : "iphone").font(.title2)
                        VStack(alignment: .leading) {
                            Text(MockDevice.current.deviceName)
                            Text("This \(MockDevice.current.deviceTypeName)").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                } header: { Text("Devices") }

                Section {
                    Button("Sign Out", role: .destructive) { confirmSignOut = true }
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Apple Account")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data),
                       let jpeg = img.preparingThumbnail(of: CGSize(width: 400, height: 400))?.jpegData(compressionQuality: 0.85) {
                        store.account?.avatarData = jpeg
                    }
                }
            }
            .confirmationDialog("Sign Out of Apple Account?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { showKeepData = true }
            } message: {
                Text("Signing out will remove iCloud data and turn off Find My for this device.")
            }
            .sheet(isPresented: $showKeepData) { KeepDataSheet { store.account = nil; dismiss() } }
        } else {
            ContentUnavailableView("Not Signed In", systemImage: "person.crop.circle.badge.xmark")
        }
    }

    private func row(_ title: String, _ icon: String, _ color: Color, value: String? = nil) -> some View {
        NavigationLink { ContentUnavailableView(title, systemImage: icon) } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(.white).frame(width: 29, height: 29)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
                Text(title)
                Spacer()
                if let value { Text(value).foregroundStyle(.secondary) }
            }
        }
    }
}

private struct KeepDataSheet: View {
    var onSignOut: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var keep: [String: Bool] = ["Contacts": true, "Calendars": true, "Safari": false, "Keychain": true]
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(keep.keys.sorted(), id: \.self) { k in
                        Toggle(k, isOn: Binding(get: { keep[k] ?? false }, set: { keep[k] = $0 }))
                    }
                } header: { Text("Keep a copy of your iCloud data on this device") }
            }
            .navigationTitle("Sign Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Sign Out") { dismiss(); onSignOut() }.tint(.red) }
            }
        }
    }
}
'''

# ============================ WI-FI ========================================

FILES["Views/Radios/Network/WiFiView.swift"] = r'''import SwiftUI

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
'''

FILES["Views/Radios/Network/NetworkRow.swift"] = r'''import SwiftUI

struct NetworkRow: View {
    enum State { case idle, connected, joining }
    let network: MockWiFiNetwork
    let state: State
    var onTap: () -> Void

    @SwiftUI.State private var showDetail = false

    var body: some View {
        HStack(spacing: 12) {
            Group {
                switch state {
                case .connected: Image(systemName: "checkmark").font(.body.weight(.semibold)).foregroundStyle(.tint)
                case .joining: ProgressView().controlSize(.small)
                case .idle: Color.clear
                }
            }
            .frame(width: 20)
            Text(network.ssid)
            Spacer()
            HStack(spacing: 10) {
                if network.security.isSecured { Image(systemName: "lock.fill") }
                Image(systemName: network.isHotspot ? "personalhotspot" : "wifi", variableValue: Double(network.signal) / 3)
                Button { showDetail = true } label: { Image(systemName: "info.circle").font(.title3) }
                    .buttonStyle(.borderless)
            }
            .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { if state == .idle { onTap() } }
        .navigationDestination(isPresented: $showDetail) { NetworkDetailView(network: network) }
    }
}
'''

FILES["Views/Radios/Network/JoinNetworkSheet.swift"] = r'''import SwiftUI

struct JoinNetworkSheet: View {
    let network: MockWiFiNetwork
    let engine: WiFiEngine
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var joining = false
    @State private var error: String?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            List {
                if network.security.isSecured {
                    Section {
                        if network.security == .enterprise {
                            TextField("Username", text: .constant("")).disabled(true)
                        }
                        SecureField("Password", text: $password).focused($focused)
                    } header: {
                        Text("Enter the password for “\(network.ssid)”")
                    } footer: {
                        Text("You can also access this Wi-Fi network by bringing your \(MockDevice.current.deviceTypeName) near any iPhone, iPad, or Mac that has connected to this network and has you in their contacts.")
                    }
                } else {
                    Section {
                        Text("“\(network.ssid)” is an unsecured network. Traffic may be visible to others.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(network.ssid)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(joining) }
                ToolbarItem(placement: .confirmationAction) {
                    if joining { ProgressView() } else {
                        Button("Join") { join() }.fontWeight(.semibold)
                            .disabled(network.security.isSecured && password.isEmpty)
                    }
                }
            }
            .alert("Unable to join the network “\(network.ssid)”", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("Dismiss", role: .cancel) {}
            } message: { Text(error ?? "") }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(joining)
    }

    private func join() {
        joining = true
        Task {
            do {
                try await engine.join(network, password: password)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            } catch {
                self.error = "Incorrect password for “\(network.ssid)”."
                password = ""
            }
            joining = false
        }
    }
}
'''

FILES["Views/Radios/Network/NetworkDetailView.swift"] = r'''import SwiftUI

struct NetworkDetailView: View {
    let network: MockWiFiNetwork
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmForget = false

    private var ssidKey: String { network.ssid.replacingOccurrences(of: " ", with: "_") }
    private var isKnown: Bool { store.knownNetworkSSIDs.contains(network.ssid) }
    private var isConnected: Bool { store.connectedSSID == network.ssid }

    var body: some View {
        List {
            if isKnown {
                Section { Button("Forget This Network", role: .destructive) { confirmForget = true } }
            }
            Section {
                ToggleRow(title: "Auto-Join", key: "wifi.\(ssidKey).autoJoin", def: true)
                ToggleRow(title: "Low Data Mode", key: "wifi.\(ssidKey).lowData", def: false)
            } footer: {
                Text("Low Data Mode helps reduce your \(MockDevice.current.deviceTypeName) data usage over your cellular network or specific Wi-Fi networks you select.")
            }
            Section {
                PickerRow(title: "Private Wi-Fi Address", key: "wifi.\(ssidKey).private", options: ["Off", "Fixed", "Rotating"], def: "Fixed")
                LabeledContent("Wi-Fi Address", value: MockDeviceIdentity.stored.wifiAddress)
                ToggleRow(title: "Limit IP Address Tracking", key: "wifi.\(ssidKey).limitIP", def: true)
            } footer: {
                Text("Using a private address helps reduce tracking of your \(MockDevice.current.deviceTypeName) across different Wi-Fi networks.")
            }
            if isConnected {
                Section("IPv4 Address") {
                    LabeledContent("Configure IP", value: "Automatic")
                    LabeledContent("IP Address", value: "192.168.1.\(Int.random(in: 20...200))")
                    LabeledContent("Subnet Mask", value: "255.255.255.0")
                    LabeledContent("Router", value: "192.168.1.1")
                }
                Section("DNS") { LabeledContent("Configure DNS", value: "Automatic") }
                Section("HTTP Proxy") { LabeledContent("Configure Proxy", value: "Off") }
            }
            Section { LabeledContent("Security", value: network.security.label) }
        }
        .navigationTitle(network.ssid)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Forget Wi-Fi Network “\(network.ssid)”?", isPresented: $confirmForget, titleVisibility: .visible) {
            Button("Forget", role: .destructive) { WiFiEngine.shared.forget(network.ssid); dismiss() }
        } message: {
            Text("Your \(MockDevice.current.deviceTypeName) will no longer join this Wi-Fi network.")
        }
    }
}

extension WiFiEngine { static let shared = WiFiEngine() }

private struct ToggleRow: View {
    let title: String; let key: String; let def: Bool
    var body: some View {
        Toggle(title, isOn: Binding(
            get: { UserDefaults.standard.object(forKey: key) as? Bool ?? def },
            set: { UserDefaults.standard.set($0, forKey: key) }))
    }
}

private struct PickerRow: View {
    let title: String; let key: String; let options: [String]; let def: String
    @State private var value = ""
    var body: some View {
        Picker(title, selection: $value) { ForEach(options, id: \.self) { Text($0) } }
            .onAppear { value = UserDefaults.standard.string(forKey: key) ?? def }
            .onChange(of: value) { _, v in UserDefaults.standard.set(v, forKey: key) }
    }
}
'''

FILES["Views/Radios/Network/OtherNetworkView.swift"] = r'''import SwiftUI

struct OtherNetworkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var security = "WPA2/WPA3"
    @State private var password = ""
    @State private var joining = false

    var body: some View {
        List {
            Section("Name") { TextField("Network Name", text: $name) }
            Section("Security") {
                Picker("Security", selection: $security) {
                    ForEach(["None", "WEP", "WPA", "WPA2/WPA3", "WPA3", "WPA2 Enterprise"], id: \.self) { Text($0) }
                }
            }
            if security != "None" {
                Section("Password") { SecureField("Password", text: $password) }
            }
        }
        .navigationTitle("Other Network")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if joining { ProgressView() } else {
                    Button("Join") {
                        joining = true
                        Task {
                            let net = MockWiFiNetwork(ssid: name, security: security == "None" ? .none : .wpa2, signal: 2, isHotspot: false)
                            try? await WiFiEngine.shared.join(net, password: security == "None" ? nil : password)
                            joining = false
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || (security != "None" && password.count < 8))
                }
            }
        }
    }
}
'''

# ============================ BATTERY ======================================

FILES["Views/Battery/BatteryView.swift"] = r'''import SwiftUI

struct BatteryView: View {
    @Environment(SettingsStore.self) private var store
    @State private var data = BatteryDataProvider.shared
    @State private var range = 0                     // 0 = Last 24 Hours, 1 = Last 10 Days
    @State private var selectedTime: Date?
    @State private var selectedDay: Date?
    @State private var showActivity = false

    private var apps: [AppBatteryUsage] {
        if range == 1, let day = data.last10d.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDay ?? .distantPast) }) {
            return day.apps
        }
        return data.todayApps
    }

    var body: some View {
        @Bindable var store = store
        List {
            Section { BatteryHeaderCard(data: data) }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            Section {
                Toggle("Low Power Mode", isOn: $store.lowPowerMode)
                if MockDevice.current.supportsAdaptivePower {
                    Toggle("Adaptive Power", isOn: $store.adaptivePower)
                }
            } header: { Text("Power Mode") } footer: {
                Text(MockDevice.current.supportsAdaptivePower
                     ? "Adaptive Power makes small performance adjustments when battery usage is higher than usual, including slightly lowering display brightness or allowing some activities to take a little longer."
                     : "Low Power Mode temporarily reduces background activity like downloads and mail fetch until you can fully charge your \(MockDevice.current.deviceTypeName).")
            }

            Section {
                NavigationLink { ChargeLimitView() } label: { LabeledContent("Charge Limit", value: "\(store.chargeLimit)%") }
                NavigationLink { BatteryHealthView(data: data) } label: {
                    LabeledContent("Battery Health", value: data.maximumCapacity >= 80 ? "Normal" : "Service")
                }
            } header: { Text("Charging") } footer: {
                Text("Last charged to \(data.lastChargedTo)% \(data.lastChargedAt.formatted(date: .omitted, time: .shortened)).")
            }

            Section { Toggle("Battery Percentage", isOn: $store.batteryPercentage) }

            Section {
                Picker("", selection: $range) {
                    Text("Last 24 Hours").tag(0)
                    Text("Last 10 Days").tag(1)
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)

                Group {
                    if range == 0 {
                        BatteryLevelChart(samples: data.last24h, selection: $selectedTime)
                    } else {
                        BatteryTenDayChart(days: data.last10d, selection: $selectedDay)
                    }
                }
                .listRowSeparator(.hidden)
                BatteryLegend()
                    .listRowSeparator(.hidden)
            } header: { Text(range == 0 ? "Battery Level" : "Battery Usage") }

            Section {
                LabeledContent("Screen On", value: minutesLabel(range == 0 ? data.screenOnMinutesToday : (selectedDayData?.screenOnMinutes ?? data.screenOnMinutesToday)))
                LabeledContent("Screen Off", value: minutesLabel(range == 0 ? data.screenOffMinutesToday : (selectedDayData?.screenOffMinutes ?? data.screenOffMinutesToday)))
            } header: { Text(range == 0 ? "Screen Usage" : "Average Screen Usage") }

            Section {
                Toggle("Show Activity", isOn: $showActivity)
                ForEach(apps) { app in BatteryAppRow(usage: app, showActivity: showActivity) }
            } header: {
                HStack {
                    Text(showActivity ? "Activity by App" : "Battery Usage by App")
                    Spacer()
                    if range == 1, let d = selectedDay { Text(d.formatted(.dateTime.weekday(.abbreviated))).textCase(nil) }
                }
            }

            Section("Insights & Suggestions") {
                HStack(spacing: 12) {
                    Image(systemName: "sun.max.fill").foregroundStyle(.white).frame(width: 29, height: 29)
                        .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.blue))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Auto-Brightness")
                        Text("Display brightness accounted for a large portion of your battery usage.").font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Battery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedDayData: BatteryDay? {
        guard let selectedDay else { return nil }
        return data.last10d.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }
    }
}

struct BatteryAppRow: View {
    let usage: AppBatteryUsage
    let showActivity: Bool
    var body: some View {
        HStack(spacing: 12) {
            AppIconView(app: usage.app, side: 29)
            VStack(alignment: .leading, spacing: 2) {
                Text(usage.app.name)
                if usage.backgroundMinutes > 0 {
                    Text("Background Activity").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if showActivity {
                Text(minutesLabel(usage.screenOnMinutes + usage.backgroundMinutes)).foregroundStyle(.secondary)
            } else {
                Text("\(Int((usage.energyShare * 100).rounded()))%").foregroundStyle(.secondary)
            }
        }
    }
}

struct BatteryLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            item(.green, "Battery Level")
            item(.green.opacity(0.35), "Charging")
            item(.yellow, "Low Power Mode")
        }
        .font(.caption).foregroundStyle(.secondary)
    }
    private func item(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 4) { RoundedRectangle(cornerRadius: 2).fill(c).frame(width: 10, height: 10); Text(t) }
    }
}

struct ChargeLimitView: View {
    @Environment(SettingsStore.self) private var store
    var body: some View {
        @Bindable var store = store
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("\(store.chargeLimit)%").font(.title.bold())
                    Slider(value: Binding(get: { Double(store.chargeLimit) }, set: { store.chargeLimit = Int(($0 / 5).rounded() * 5) }), in: 80...100, step: 5)
                }
            } footer: {
                Text("Choose a charge limit between 80% and 100%. Limiting charge to a lower percentage can help improve battery lifespan.")
            }
            Section { Toggle("Optimized Battery Charging", isOn: $store.optimizedCharging) } footer: {
                Text("To reduce battery aging, \(MockDevice.current.deviceTypeName) learns from your daily charging routine so it can wait to finish charging past \(store.chargeLimit)% until you need to use it.")
            }
        }
        .navigationTitle("Charge Limit")
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

FILES["Views/Battery/BatteryHeaderCard.swift"] = r'''import SwiftUI

struct BatteryHeaderCard: View {
    let data: BatteryDataProvider

    private var sentence: String {
        let diff = data.todayUsagePercent - data.dailyAveragePercent
        if abs(diff) <= 8 { return "Battery usage is similar to your typical usage." }
        return diff > 0 ? "Battery usage is higher than your typical usage." : "Battery usage is lower than your typical usage."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(data.currentLevel)%").font(.system(size: 44, weight: .semibold, design: .rounded))
                Image(systemName: "battery.100percent").font(.title2).foregroundStyle(.green)
                Spacer()
            }
            Text("Charged to \(data.lastChargedTo)% · \(data.lastChargedAt.formatted(date: .omitted, time: .shortened))")
                .font(.footnote).foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                bar("Today", value: data.todayUsagePercent, max: 130, color: .green)
                bar("Daily average", value: data.dailyAveragePercent, max: 130, color: .secondary.opacity(0.35))
                Text(sentence).font(.footnote).foregroundStyle(.secondary).padding(.top, 2)
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private func bar(_ label: String, value: Int, max: Int, color: some ShapeStyle) -> some View {
        HStack(spacing: 10) {
            Text(label).font(.footnote).frame(width: 96, alignment: .leading)
            GeometryReader { g in
                Capsule().fill(color).frame(width: g.size.width * CGFloat(value) / CGFloat(max))
            }
            .frame(height: 10)
            Text("\(value)%").font(.footnote.monospacedDigit()).frame(width: 44, alignment: .trailing)
        }
    }
}
'''

FILES["Views/Battery/BatteryLevelChart.swift"] = r'''import SwiftUI
import Charts

struct BatteryLevelChart: View {
    let samples: [BatterySample]
    @Binding var selection: Date?

    var body: some View {
        Chart {
            ForEach(samples) { s in
                if s.charging {
                    RectangleMark(xStart: .value("s", s.date), xEnd: .value("e", s.date.addingTimeInterval(900)),
                                  yStart: .value("0", 0), yEnd: .value("100", 100))
                        .foregroundStyle(Color.green.opacity(0.12))
                }
                if s.lowPower {
                    RectangleMark(xStart: .value("s", s.date), xEnd: .value("e", s.date.addingTimeInterval(900)),
                                  yStart: .value("0", 0), yEnd: .value("100", 100))
                        .foregroundStyle(Color.yellow.opacity(0.18))
                }
                AreaMark(x: .value("Time", s.date), y: .value("Level", s.level * 100))
                    .foregroundStyle(Color.green.opacity(s.charging ? 0.25 : 0.45))
                    .interpolationMethod(.stepEnd)
                LineMark(x: .value("Time", s.date), y: .value("Level", s.level * 100))
                    .foregroundStyle(Color.green)
                    .interpolationMethod(.stepEnd)
            }
            if let selection, let s = samples.nearest(to: selection) {
                RuleMark(x: .value("Selected", s.date)).foregroundStyle(.secondary)
                    .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.date.formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
                            Text("\(Int(s.level * 100))%").font(.headline)
                            if s.charging { Text("Charging").font(.caption2).foregroundStyle(.green) }
                        }
                        .padding(8)
                        .glassCard(cornerRadius: 10)
                    }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100]) { v in
                AxisGridLine()
                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)%") }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .chartXSelection(value: $selection)
        .frame(height: 170)
    }
}

struct BatteryTenDayChart: View {
    let days: [BatteryDay]
    @Binding var selection: Date?

    var body: some View {
        Chart {
            ForEach(days) { d in
                BarMark(x: .value("Day", d.date, unit: .day), y: .value("Used", d.percentUsed))
                    .foregroundStyle(Color.green)
                    .opacity(selection == nil || Calendar.current.isDate(selection ?? .distantPast, inSameDayAs: d.date) ? 1 : 0.35)
                    .cornerRadius(3)
            }
            if let sel = selection, let d = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: sel) }) {
                RuleMark(x: .value("Selected", d.date, unit: .day)).foregroundStyle(.clear)
                    .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(d.date.formatted(.dateTime.weekday(.wide))).font(.caption2).foregroundStyle(.secondary)
                            Text("\(d.percentUsed)%").font(.headline)
                        }
                        .padding(8).glassCard(cornerRadius: 10)
                    }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100, 150]) { v in
                AxisGridLine()
                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)%") }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true) }
        }
        .chartXSelection(value: $selection)
        .frame(height: 170)
    }
}
'''

FILES["Views/Battery/BatteryHealthView.swift"] = r'''import SwiftUI

struct BatteryHealthView: View {
    let data: BatteryDataProvider
    var body: some View {
        List {
            Section {
                LabeledContent("Maximum Capacity", value: "\(data.maximumCapacity)%")
            } footer: {
                Text("This is a measure of battery capacity relative to when it was new. Lower capacity may result in fewer hours of usage between charges.")
            }
            Section {
                LabeledContent("Cycle Count", value: "\(data.cycleCount)")
                LabeledContent("Manufacture Date", value: Date.daysAgo(410).formatted(.dateTime.month(.wide).year()))
                LabeledContent("First Use", value: Date.daysAgo(380).formatted(.dateTime.month(.wide).year()))
            } footer: {
                Text("Your battery is currently supporting normal peak performance.")
            }
            Section {
                Link("About Battery & Performance…", destination: URL(string: "https://support.apple.com/en-us/HT208387")!)
            }
        }
        .navigationTitle("Battery Health")
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

# ============================ SCREEN TIME ==================================

FILES["Views/Screen Time/ScreenTimeView.swift"] = r'''import SwiftUI

struct ScreenTimeView: View {
    @State private var provider = ScreenTimeProvider.shared
    @AppStorage("screentime.share") private var shareAcrossDevices = false
    @AppStorage("screentime.enabled") private var enabled = true
    @State private var confirmOff = false

    var body: some View {
        List {
            if enabled {
                Section { ScreenTimeCard(provider: provider) }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                Section {
                    NavigationLink { ScreenTimeActivityView(provider: provider) } label: { LabeledContent("App & Website Activity", value: "On") }
                }
                Section("Limit Usage") {
                    link("Downtime", "moon.fill", .indigo) { DowntimeView() }
                    link("App Limits", "hourglass", .orange) { AppLimitsView() }
                    link("Always Allowed", "checkmark.circle.fill", .green) { AlwaysAllowedView() }
                    link("Screen Distance", "eyeglasses", .teal) { ScreenDistanceView() }
                }
                Section("Communication") {
                    link("Communication Limits", "person.2.fill", .green) { ContentUnavailableView("Communication Limits", systemImage: "person.2.fill") }
                    link("Communication Safety", "bubble.left.and.exclamationmark.bubble.right.fill", .blue) { ContentUnavailableView("Communication Safety", systemImage: "bubble.left.fill") }
                }
                Section("Restrictions") {
                    link("Content & Privacy Restrictions", "nosign", .red) { ContentPrivacyGateView() }
                }
                Section { link("Set Up Screen Time for Family", "figure.2.and.child.holdinghands", .blue) { ContentUnavailableView("Family", systemImage: "figure.2.and.child.holdinghands") } } footer: {
                    Text("Set up Family Sharing to use Screen Time with your family’s devices.")
                }
                Section { link("Lock Screen Time Settings", "lock.fill", .gray) { ContentUnavailableView("Lock Screen Time Settings", systemImage: "lock.fill") } } footer: {
                    Text("Use a passcode to secure Screen Time settings.")
                }
                Section { Toggle("Share Across Devices", isOn: $shareAcrossDevices) } footer: {
                    Text("You can enable this on any device signed in to iCloud to report your combined screen time.")
                }
                Section {
                    Button("Turn Off App & Website Activity", role: .destructive) { confirmOff = true }
                }
            } else {
                Section {
                    Button("Turn On App & Website Activity") { withAnimation { enabled = true } }
                } footer: { Text("Get reports about your screen time and set limits for what you want to manage.") }
            }
        }
        .navigationTitle("Screen Time")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Turn Off App & Website Activity?", isPresented: $confirmOff, titleVisibility: .visible) {
            Button("Turn Off App & Website Activity", role: .destructive) { withAnimation { enabled = false } }
        } message: { Text("Reports and limits will be turned off and your activity data will be deleted.") }
    }

    private func link<D: View>(_ title: String, _ icon: String, _ color: Color, @ViewBuilder destination: @escaping () -> D) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(.white).font(.footnote.weight(.semibold))
                    .frame(width: 29, height: 29)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
                Text(title)
            }
        }
    }
}

struct ScreenTimeCard: View {
    let provider: ScreenTimeProvider
    @State private var selectedDay: Date?
    var body: some View {
        NavigationLink { ScreenTimeActivityView(provider: provider) } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Text(MockDevice.current.deviceName).font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
                }
                Text("DAILY AVERAGE").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(minutesLabel(provider.dailyAverage)).font(.title.bold())
                    DeltaPill(percent: provider.deltaPercent)
                }
                ScreenTimeWeekChart(days: provider.week, average: provider.dailyAverage, selectedDay: $selectedDay)
                LegendRow(categories: provider.weekTopCategories)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DeltaPill: View {
    let percent: Int
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: percent >= 0 ? "arrow.up" : "arrow.down").font(.caption2.bold())
            Text("\(abs(percent))% from last week").font(.caption)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Capsule().fill((percent >= 0 ? Color.red : Color.green).opacity(0.15)))
        .foregroundStyle(percent >= 0 ? .red : .green)
    }
}

struct LegendRow: View {
    let categories: [ScreenTimeCategory]
    var body: some View {
        HStack(spacing: 14) {
            ForEach(categories, id: \.self) { c in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(c.color).frame(width: 10, height: 10)
                    Text(c.rawValue).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
        }
    }
}
'''

FILES["Views/Screen Time/ScreenTimeWeekChart.swift"] = r'''import SwiftUI
import Charts

struct ScreenTimeWeekChart: View {
    let days: [ScreenTimeDay]
    let average: Int
    @Binding var selectedDay: Date?

    private func isSelected(_ day: ScreenTimeDay) -> Bool {
        guard let selectedDay else { return true }
        return Calendar.current.isDate(selectedDay, inSameDayAs: day.date)
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                ForEach(ScreenTimeCategory.allCases, id: \.self) { cat in
                    BarMark(x: .value("Day", day.date, unit: .day), y: .value("Minutes", day.byCategory[cat] ?? 0))
                        .foregroundStyle(by: .value("Category", cat))
                        .opacity(isSelected(day) ? 1 : 0.35)
                }
            }
            RuleMark(y: .value("avg", average))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                .foregroundStyle(.secondary)
                .annotation(position: .top, alignment: .trailing) { Text("avg").font(.caption2).foregroundStyle(.secondary) }
        }
        .chartForegroundStyleScale(domain: ScreenTimeCategory.allCases, range: ScreenTimeCategory.allCases.map(\.color))
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true) }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 120, 240, 360]) { v in
                AxisGridLine()
                AxisValueLabel { Text(minutesLabel(v.as(Int.self) ?? 0)) }
            }
        }
        .chartXSelection(value: $selectedDay)
        .frame(height: 150)
    }
}

struct ScreenTimeDayChart: View {
    let day: ScreenTimeDay
    var body: some View {
        Chart {
            ForEach(0..<24, id: \.self) { h in
                ForEach(ScreenTimeCategory.allCases, id: \.self) { cat in
                    BarMark(x: .value("Hour", h), y: .value("Minutes", day.hourly[h][cat] ?? 0))
                        .foregroundStyle(by: .value("Category", cat))
                }
            }
        }
        .chartForegroundStyleScale(domain: ScreenTimeCategory.allCases, range: ScreenTimeCategory.allCases.map(\.color))
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18]) { v in
                AxisValueLabel { Text(["12 AM", "6 AM", "12 PM", "6 PM"][(v.as(Int.self) ?? 0) / 6]) }
            }
        }
        .chartYAxis { AxisMarks(position: .trailing, values: [0, 30, 60]) { v in AxisGridLine(); AxisValueLabel { Text(minutesLabel(v.as(Int.self) ?? 0)) } } }
        .frame(height: 150)
    }
}
'''

FILES["Views/Screen Time/ScreenTimeActivityView.swift"] = r'''import SwiftUI

struct ScreenTimeActivityView: View {
    let provider: ScreenTimeProvider
    @State private var mode = 1          // 0 Day, 1 Week
    @State private var selectedDay: Date?

    private var day: ScreenTimeDay { provider.day(for: selectedDay) ?? provider.today }
    private var mostUsed: [AppUsage] {
        if mode == 0 { return day.mostUsed }
        var totals: [String: (MockApp, Int)] = [:]
        for d in provider.week { for u in d.mostUsed { totals[u.app.bundleID, default: (u.app, 0)].1 += u.minutes } }
        return totals.values.map { AppUsage(app: $0.0, minutes: $0.1) }.sorted { $0.minutes > $1.minutes }
    }

    var body: some View {
        List {
            Section {
                Picker("", selection: $mode) { Text("Day").tag(0); Text("Week").tag(1) }
                    .pickerStyle(.segmented).listRowSeparator(.hidden)
                VStack(alignment: .leading, spacing: 8) {
                    Text(mode == 0 ? "SCREEN TIME" : "DAILY AVERAGE").font(.caption).foregroundStyle(.secondary)
                    HStack {
                        Text(minutesLabel(mode == 0 ? day.total : provider.dailyAverage)).font(.title.bold())
                        if mode == 1 { DeltaPill(percent: provider.deltaPercent) }
                    }
                    if mode == 0 { ScreenTimeDayChart(day: day) }
                    else { ScreenTimeWeekChart(days: provider.week, average: provider.dailyAverage, selectedDay: $selectedDay) }
                    LegendRow(categories: mode == 0 ? day.topCategories : provider.weekTopCategories)
                }
                .listRowSeparator(.hidden)
            }

            Section("Most Used") {
                let maxM = mostUsed.first?.minutes ?? 1
                ForEach(mostUsed) { u in
                    HStack(spacing: 12) {
                        AppIconView(app: u.app, side: 32)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack { Text(u.app.name); Spacer(); Text(minutesLabel(u.minutes)).foregroundStyle(.secondary) }
                            GeometryReader { g in
                                Capsule().fill(u.app.category.screenTimeCategory.color)
                                    .frame(width: g.size.width * CGFloat(u.minutes) / CGFloat(maxM))
                            }.frame(height: 4)
                        }
                    }
                }
            }
            Section("Pickups") {
                LabeledContent(mode == 0 ? "Total Pickups" : "Average Pickups", value: "\(mode == 0 ? day.pickups : provider.week.map(\.pickups).reduce(0, +) / 7)")
                LabeledContent("First Pickup", value: "7:41 AM")
            }
            Section("Notifications") {
                LabeledContent(mode == 0 ? "Total" : "Daily Average", value: "\(mode == 0 ? day.notifications : provider.week.map(\.notifications).reduce(0, +) / 7)")
            }
        }
        .navigationTitle(MockDevice.current.deviceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension AppLibraryCategory {
    var screenTimeCategory: ScreenTimeCategory {
        switch self {
        case .social: return .social
        case .entertainment: return .entertainment
        case .creativity: return .creativity
        case .productivity, .utilities: return .productivity
        case .games: return .games
        case .information: return .information
        default: return .other
        }
    }
}
'''

FILES["Views/Screen Time/ScreenTimeSubViews.swift"] = r'''import SwiftUI

struct DowntimeView: View {
    @AppStorage("downtime.scheduled") private var scheduled = false
    @AppStorage("downtime.from") private var from = Date.now.timeIntervalSince1970
    @AppStorage("downtime.to") private var to = Date.now.timeIntervalSince1970
    @AppStorage("downtime.block") private var blockAtDowntime = false
    var body: some View {
        List {
            Section { Button("Turn On Downtime Until Tomorrow") {} } footer: {
                Text("Set a schedule for time away from the screen. During downtime, only apps that you choose to allow and phone calls will be available.")
            }
            Section {
                Toggle("Scheduled", isOn: $scheduled)
                if scheduled {
                    DatePicker("From", selection: Binding(get: { Date(timeIntervalSince1970: from) }, set: { from = $0.timeIntervalSince1970 }), displayedComponents: .hourAndMinute)
                    DatePicker("To", selection: Binding(get: { Date(timeIntervalSince1970: to) }, set: { to = $0.timeIntervalSince1970 }), displayedComponents: .hourAndMinute)
                }
            }
            Section { Toggle("Block at Downtime", isOn: $blockAtDowntime) } footer: {
                Text("Apps that are not allowed will be blocked during downtime.")
            }
        }
        .navigationTitle("Downtime")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppLimitsView: View {
    struct Limit: Identifiable { let id = UUID(); let category: ScreenTimeCategory; let minutes: Int }
    @State private var limits: [Limit] = [Limit(category: .social, minutes: 90)]
    @State private var adding = false
    @AppStorage("applimits.enabled") private var enabled = true
    var body: some View {
        List {
            Section {
                Toggle("App Limits", isOn: $enabled)
                ForEach(limits) { l in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(l.category.color).frame(width: 29, height: 29)
                            .overlay(Image(systemName: "hourglass").font(.caption).foregroundStyle(.white))
                        VStack(alignment: .leading) { Text(l.category.rawValue); Text(minutesLabel(l.minutes)).font(.footnote).foregroundStyle(.secondary) }
                    }
                }
                .onDelete { limits.remove(atOffsets: $0) }
                Button("Add Limit") { adding = true }
            } footer: { Text("Set daily time limits for app categories you want to manage. Limits reset every day at midnight.") }
        }
        .navigationTitle("App Limits")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $adding) { AddLimitSheet { limits.append(Limit(category: $0, minutes: $1)) } }
    }
}

private struct AddLimitSheet: View {
    var onAdd: (ScreenTimeCategory, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var category: ScreenTimeCategory = .social
    @State private var minutes = 60
    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(ScreenTimeCategory.allCases, id: \.self) { c in
                        HStack {
                            RoundedRectangle(cornerRadius: 6).fill(c.color).frame(width: 24, height: 24)
                            Text(c.rawValue); Spacer()
                            if c == category { Image(systemName: "checkmark").foregroundStyle(.tint) }
                        }
                        .contentShape(Rectangle()).onTapGesture { category = c }
                    }
                }
                Section("Time") { Stepper("\(minutesLabel(minutes))", value: $minutes, in: 15...480, step: 15) }
            }
            .navigationTitle("Choose Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Add") { onAdd(category, minutes); dismiss() } }
            }
        }
    }
}

struct AlwaysAllowedView: View {
    @State private var allowed: Set<String> = ["com.mock.pingme", "com.mock.wander"]
    var body: some View {
        List {
            Section("Allowed Apps") {
                ForEach(MockAppCatalog.all.filter { allowed.contains($0.bundleID) }) { app in
                    HStack(spacing: 12) {
                        Button { allowed.remove(app.bundleID) } label: { Image(systemName: "minus.circle.fill").foregroundStyle(.red) }.buttonStyle(.borderless)
                        AppIconView(app: app, side: 29); Text(app.name)
                    }
                }
            }
            Section("Choose Apps") {
                ForEach(MockAppCatalog.all.filter { !allowed.contains($0.bundleID) }) { app in
                    HStack(spacing: 12) {
                        Button { allowed.insert(app.bundleID) } label: { Image(systemName: "plus.circle.fill").foregroundStyle(.green) }.buttonStyle(.borderless)
                        AppIconView(app: app, side: 29); Text(app.name)
                    }
                }
            }
        }
        .navigationTitle("Always Allowed")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScreenDistanceView: View {
    @AppStorage("screenDistance") private var on = false
    var body: some View {
        List {
            Section { Toggle("Screen Distance", isOn: $on) } footer: {
                Text("Screen Distance uses the TrueDepth camera to encourage you to move your \(MockDevice.current.deviceTypeName) farther away after holding it closer than 12 inches for an extended period.")
            }
        }
        .navigationTitle("Screen Distance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Content & Privacy Restrictions behind the mock passcode.
struct ContentPrivacyGateView: View {
    @State private var unlocked = false
    @State private var showPasscode = true
    @AppStorage("cpr.enabled") private var enabled = false
    var body: some View {
        Group {
            if unlocked {
                List {
                    Section { Toggle("Content & Privacy Restrictions", isOn: $enabled) }
                    Section {
                        NavigationLink("iTunes & App Store Purchases") { ContentUnavailableView("Purchases", systemImage: "cart") }
                        NavigationLink("Allowed Apps & Features") { ContentUnavailableView("Allowed Apps", systemImage: "app") }
                        NavigationLink("Store, Web, Siri & Game Center Content") { ContentUnavailableView("Content", systemImage: "globe") }
                    }.disabled(!enabled)
                }
            } else {
                Color.clear
            }
        }
        .navigationTitle("Content & Privacy Restrictions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPasscode) { MockPasscodeSheet(title: "Enter Screen Time Passcode") { unlocked = $0 } }
    }
}
'''

# ============================ ANALYTICS ====================================

FILES["Views/Privacy & Security/AnalyticsImprovementsView.swift"] = r'''import SwiftUI

struct AnalyticsImprovementsView: View {
    @AppStorage("analytics.share") private var share = true
    @AppStorage("analytics.icloud") private var icloud = false
    @AppStorage("analytics.siri") private var siri = false
    @AppStorage("analytics.safety") private var safety = true
    @AppStorage("analytics.assistive") private var assistive = false
    @AppStorage("analytics.developers") private var developers = true

    var body: some View {
        List {
            Section {
                Toggle("Share \(MockDevice.current.deviceTypeName) Analytics", isOn: $share)
            } footer: {
                Text("Help Apple improve its products and services by automatically sending daily diagnostic and usage data. Data may include location information. Analytics uses wireless data. [About Analytics & Privacy…](https://www.apple.com/privacy)")
            }
            Section {
                NavigationLink("Analytics Data") { AnalyticsDataView() }
            }
            Section { Toggle("Share iCloud Analytics", isOn: $icloud) } footer: {
                Text("Help Apple improve Siri and other intelligent features by analyzing how you use iCloud data from your account.")
            }
            Section { Toggle("Improve Siri & Dictation", isOn: $siri) } footer: {
                Text("Help improve Siri and Dictation by allowing Apple to store and review audio of your Siri and Dictation interactions.")
            }
            Section { Toggle("Improve Safety", isOn: $safety) } footer: {
                Text("Help improve safety features by sharing data about crash detection and emergency calls.")
            }
            Section { Toggle("Improve Assistive Voice Features", isOn: $assistive) }
            Section { Toggle("Share with App Developers", isOn: $developers) } footer: {
                Text("Help app developers improve their apps by allowing Apple to share crash data and statistics on how you use their apps.")
            }
        }
        .navigationTitle("Analytics & Improvements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

FILES["Views/Privacy & Security/AnalyticsDataView.swift"] = r'''import SwiftUI

struct AnalyticsDataView: View {
    @State private var store = AnalyticsStore.shared
    @State private var confirmDelete = false

    var body: some View {
        List(store.files) { file in
            NavigationLink(value: file) {
                Text(file.name).font(.footnote).lineLimit(1).truncationMode(.middle)
            }
        }
        .navigationTitle("Analytics Data")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AnalyticsFile.self) { AnalyticsFileDetailView(file: $0) }
        .refreshable { store.reload() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink("Share All…", items: store.files.map(\.url))
                    Button("Delete All", systemImage: "trash", role: .destructive) { confirmDelete = true }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .confirmationDialog("Delete all analytics data?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) { store.deleteAll() }
        }
        .overlay { if store.files.isEmpty { ContentUnavailableView("No Analytics Data", systemImage: "doc.text") } }
    }
}

struct AnalyticsFileDetailView: View {
    let file: AnalyticsFile
    @State private var text = ""

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: file.url, preview: SharePreview(file.name, image: Image(systemName: "doc.text")))
            }
        }
        .task { text = AnalyticsStore.shared.contents(of: file) }
    }
}
'''

# ============================ APP LIBRARY ==================================

FILES["Views/App Library/AppLibraryView.swift"] = r'''import SwiftUI

/// Add `NavigationLink("App Library") { AppLibraryView() }` to HomeScreenView.
struct AppLibraryView: View {
    @Environment(SettingsStore.self) private var store
    @State private var query = ""
    @Namespace private var ns

    private var categories: [AppLibraryCategory] {
        AppLibraryCategory.allCases.filter { !MockAppCatalog.apps(in: $0, excluding: store.hiddenAppBundleIDs).isEmpty }
    }
    private var searchResults: [MockApp] {
        MockAppCatalog.all
            .filter { !store.hiddenAppBundleIDs.contains($0.bundleID) }
            .filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.16, green: 0.24, blue: 0.48), Color(red: 0.55, green: 0.32, blue: 0.62)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if query.isEmpty { folderGrid } else { alphabeticalList }
        }
        .navigationTitle("App Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "App Library")
    }

    private var folderGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 22) {
                ForEach(categories, id: \.self) { cat in
                    CategoryFolderTile(category: cat, apps: MockAppCatalog.apps(in: cat, excluding: store.hiddenAppBundleIDs), namespace: ns)
                }
                HiddenFolderTile(namespace: ns)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private var alphabeticalList: some View {
        let grouped = Dictionary(grouping: searchResults) { String($0.name.prefix(1)).uppercased() }
        return ScrollViewReader { proxy in
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { letter in
                    Section(letter) {
                        ForEach(grouped[letter] ?? []) { app in
                            HStack(spacing: 12) { AppIconView(app: app, side: 36); Text(app.name) }
                        }
                    }
                    .id(letter)
                }
            }
            .scrollContentBackground(.hidden)
            .overlay(alignment: .trailing) {
                VStack(spacing: 2) {
                    ForEach(grouped.keys.sorted(), id: \.self) { l in
                        Text(l).font(.caption2.bold()).foregroundStyle(.white)
                            .onTapGesture { withAnimation { proxy.scrollTo(l, anchor: .top) } }
                    }
                }
                .padding(.trailing, 4)
            }
        }
    }
}
'''

FILES["Views/App Library/CategoryFolderTile.swift"] = r'''import SwiftUI

struct CategoryFolderTile: View {
    let category: AppLibraryCategory
    let apps: [MockApp]
    let namespace: Namespace.ID
    @State private var expanded = false

    private var showsFourLarge: Bool { category == .suggestions || category == .recentlyAdded || apps.count <= 4 }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous).fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 0.5))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    if showsFourLarge {
                        ForEach(apps.prefix(4)) { app in
                            AppIconView(app: app, side: 60).contextMenu { AppContextMenu(app: app) }
                        }
                    } else {
                        ForEach(apps.prefix(3)) { app in
                            AppIconView(app: app, side: 60).contextMenu { AppContextMenu(app: app) }
                        }
                        MiniCluster(apps: Array(apps.dropFirst(3)))
                    }
                }
                .padding(18)
            }
            .frame(width: 168, height: 168)
            .matchedTransitionSourceCompat(id: category.rawValue, in: namespace)
            .onTapGesture { expanded = true }
            Text(category.rawValue).font(.footnote).foregroundStyle(.white).lineLimit(1)
        }
        .navigationDestination(isPresented: $expanded) {
            FolderExpandedView(title: category.rawValue, apps: apps)
                .zoomTransitionCompat(sourceID: category.rawValue, in: namespace)
        }
    }
}

struct MiniCluster: View {
    let apps: [MockApp]
    var body: some View {
        let cols = apps.count > 4 ? 3 : 2
        let side: CGFloat = cols == 3 ? 15 : 24
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(.white.opacity(0.18))
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(side), spacing: 4), count: cols), spacing: 4) {
                ForEach(apps.prefix(cols * cols)) { AppIconView(app: $0, side: side) }
            }
        }
        .frame(width: 60, height: 60)
    }
}

struct AppContextMenu: View {
    let app: MockApp
    @Environment(SettingsStore.self) private var store
    var isHidden: Bool { store.hiddenAppBundleIDs.contains(app.bundleID) }
    var body: some View {
        Button("Add to Home Screen", systemImage: "plus.square.on.square") {}
        Button("Share App", systemImage: "square.and.arrow.up") {}
        Button(isHidden ? "Don’t Require Face ID" : "Require Face ID", systemImage: isHidden ? "faceid" : "faceid") {
            withAnimation(.spring) {
                if isHidden { store.hiddenAppBundleIDs.remove(app.bundleID) } else { store.hiddenAppBundleIDs.insert(app.bundleID) }
            }
        }
        Button("Delete App", systemImage: "trash", role: .destructive) {}
    }
}

extension View {
    @ViewBuilder
    func matchedTransitionSourceCompat(id: String, in ns: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) { self.matchedTransitionSource(id: id, in: ns) } else { self }
    }
    @ViewBuilder
    func zoomTransitionCompat(sourceID: String, in ns: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) { self.navigationTransition(.zoom(sourceID: sourceID, in: ns)) } else { self }
    }
}
'''

FILES["Views/App Library/FolderExpandedView.swift"] = r'''import SwiftUI

struct FolderExpandedView: View {
    let title: String
    let apps: [MockApp]
    @State private var appeared = false

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                    ForEach(Array(apps.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 6) {
                            AppIconView(app: app, side: 62).contextMenu { AppContextMenu(app: app) }
                            Text(app.name).font(.caption).lineLimit(1)
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.7)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(i) * 0.04), value: appeared)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}
'''

FILES["Views/App Library/HiddenFolderTile.swift"] = r'''import SwiftUI

/// Bottom-of-library Hidden folder: Face ID / passcode gate + de-blur reveal animation.
struct HiddenFolderTile: View {
    let namespace: Namespace.ID
    @Environment(SettingsStore.self) private var store
    @State private var unlocked = false
    @State private var expanded = false
    @State private var showPasscode = false
    @State private var shake = 0

    private var hidden: [MockApp] { MockAppCatalog.all.filter { store.hiddenAppBundleIDs.contains($0.bundleID) } }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous).fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 0.5))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(hidden.prefix(4)) { app in
                        AppIconView(app: app, side: 60)
                            .blur(radius: unlocked ? 0 : 14)
                            .saturation(unlocked ? 1 : 0)
                            .scaleEffect(unlocked ? 1 : 0.92)
                    }
                }
                .padding(18)
                Image(systemName: "eye.slash.fill")
                    .font(.title).foregroundStyle(.white.opacity(0.9))
                    .opacity(unlocked ? 0 : 1)
                    .scaleEffect(unlocked ? 1.6 : 1)
            }
            .frame(width: 168, height: 168)
            .matchedTransitionSourceCompat(id: "hidden", in: namespace)
            .modifier(ShakeEffect(shakes: shake))
            .onTapGesture { Task { await unlock() } }
            Text("Hidden").font(.footnote).foregroundStyle(.white)
        }
        .navigationDestination(isPresented: $expanded) {
            HiddenFolderExpandedView(apps: hidden)
                .zoomTransitionCompat(sourceID: "hidden", in: namespace)
        }
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                showPasscode = false
                if ok { reveal() } else { fail() }
            }
        }
        .onChange(of: expanded) { _, isExpanded in
            if !isExpanded { withAnimation(.easeOut(duration: 0.3)) { unlocked = false } }   // re-lock on return
        }
    }

    private func unlock() async {
        guard store.requireAuthForHiddenApps else { reveal(); return }
        switch await HiddenAppsAuth.authenticate() {
        case .some(true): reveal()
        case .some(false): fail()
        case .none: showPasscode = true
        }
    }

    private func reveal() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) { unlocked = true }   // phase 1: de-blur
        Task {
            try? await Task.sleep(for: .milliseconds(420))
            withAnimation(.smooth(duration: 0.35)) { expanded = true }                      // phase 2: zoom in
        }
    }

    private func fail() {
        withAnimation(.default) { shake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

struct HiddenFolderExpandedView: View {
    let apps: [MockApp]
    @Environment(SettingsStore.self) private var store
    @State private var appeared = false

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            if apps.isEmpty {
                ContentUnavailableView("No Hidden Apps", systemImage: "eye.slash", description: Text("Touch and hold an app and choose Require Face ID to hide it."))
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                    ForEach(Array(apps.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 6) {
                            AppIconView(app: app, side: 62)
                                .contextMenu {
                                    Button("Unhide", systemImage: "eye") { withAnimation(.spring) { store.hiddenAppBundleIDs.remove(app.bundleID) } }
                                }
                            Text(app.name).font(.caption).lineLimit(1)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.7)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(i) * 0.05), value: appeared)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Hidden")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}

/// Drop this Section into FaceIDPasscodeView ("Use Face ID For").
struct HiddenAppsSettingsSection: View {
    @Environment(SettingsStore.self) private var store
    @State private var showChange = false
    var body: some View {
        @Bindable var store = store
        Section {
            Toggle("Hidden Apps", isOn: $store.requireAuthForHiddenApps)
            Button("Change Mock Passcode") { showChange = true }
        } footer: {
            Text("Require Face ID or your passcode to reveal apps in the Hidden folder of the App Library. Current mock passcode: \(store.mockPasscode)")
        }
        .alert("New Passcode", isPresented: $showChange) {
            TextField("6 digits", text: $store.mockPasscode).keyboardType(.numberPad)
            Button("Done") { store.mockPasscode = String(store.mockPasscode.filter(\.isNumber).prefix(6)) }
        }
    }
}
'''
FILES["README_iOS26_INTEGRATION.md"] = r'''# iOS 26 realism – integration steps

Files were generated by `generate_ios26.py`. Old files with the same name were copied to
`_ios26_backup/` before being replaced. Finish the wiring below and build
(Xcode 16/26, iOS 18+ target; Liquid Glass modifiers are `#available(iOS 26)`-guarded).

## 1. Inject the store
In `SettingsApp.swift`:

~~~swift
WindowGroup {
    ContentView()
        .environment(SettingsStore.shared)
}
~~~

## 2. Root list
* Replace the old Apple Account header row with `AppleAccountRow()`.
* Make sure the rows that push `WiFiView()`, `BatteryView()`, `ScreenTimeView()`,
  `AboutView()`, `AnalyticsImprovementsView()` use the **no-argument** initializers
  (the generated views take no parameters).

## 3. Developer Mode
* `*Developer*.swift` files were moved to `_ios26_backup/`.
* Remove the `SettingsItem` / enum case / `@AppStorage("developerMode")` references the
  script listed under "Remaining Developer references" (the compiler will show them too).

## 4. App Library entry point
In `HomeScreenView.swift` add at the top:

~~~swift
Section { NavigationLink("App Library") { AppLibraryView() } }
~~~

## 5. Hidden Apps toggle
In `FaceIDPasscodeView.swift` add `HiddenAppsSettingsSection()` under "Use Face ID For".

## 6. Info.plist
`NSFaceIDUsageDescription` was added if an Info.plist exists. If the target uses
`GENERATE_INFOPLIST_FILE = YES`, add key **Privacy - Face ID Usage Description** in
Target > Info instead.

## 7. Xcode project membership
If `project.pbxproj` uses synchronized folders (Xcode 16+), the new files are picked up
automatically. Otherwise drag the new folders into the Xcode navigator (Create groups, add
to the app target).

## Test accounts / codes
* Apple Account: any e-mail + any password (>=4 chars) + any 6-digit code.
* Wi-Fi: passwords shorter than 8 characters fail ("Incorrect password").
* Hidden Apps mock passcode: `000000` (change in Face ID & Passcode).
'''

# ---------------------------------------------------------------------------
# GENERATOR LOGIC
# ---------------------------------------------------------------------------
SKIP_DIRS = {".git", "_ios26_backup", "DerivedData", "build", ".build", "Pods"}


def _skip(path: Path) -> bool:
    return any(part in SKIP_DIRS or part.endswith(".xcodeproj") or part.endswith(".xcworkspace")
               for part in path.parts)


def find_target_dir(repo: Path) -> Path:
    for cand in ("Preferences", "Settings-iOS", "Settings"):
        p = repo / cand
        if p.is_dir() and any(p.rglob("*App.swift")):
            return p
    for app_file in repo.rglob("*App.swift"):
        if not _skip(app_file):
            return app_file.parent
    return repo / "Preferences"


def iter_swift_files(repo: Path):
    for p in repo.rglob("*.swift"):
        if not _skip(p):
            yield p


def backup_path(repo: Path, path: Path, backup: Path) -> Path:
    try:
        rel = path.relative_to(repo)
    except ValueError:
        rel = Path(path.name)
    return backup / rel


def move_to_backup(repo: Path, path: Path, backup: Path, dry: bool):
    dest = backup_path(repo, path, backup)
    print(f"  -> move to backup   {path.relative_to(repo)}")
    if not dry:
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists():
            dest.unlink()
        shutil.move(str(path), str(dest))


def copy_to_backup(repo: Path, path: Path, backup: Path, dry: bool):
    dest = backup_path(repo, path, backup)
    print(f"  -> copy to backup   {path.relative_to(repo)}")
    if not dry:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(path), str(dest))


def main():
    ap = argparse.ArgumentParser(description="Generate iOS 26 files for Settings-iOS")
    ap.add_argument("--repo", default=".", help="repository root (default: .)")
    ap.add_argument("--target", default=None, help="app target folder (auto-detected)")
    ap.add_argument("--out", default=None, help="write into this separate folder instead of the repo")
    ap.add_argument("--no-backup", action="store_true", help="do not move clashing / Developer files")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    if not repo.is_dir():
        sys.exit(f"repo not found: {repo}")

    target = Path(args.target).resolve() if args.target else find_target_dir(repo)
    out_root = Path(args.out).resolve() if args.out else target
    backup = repo / "_ios26_backup"
    dry = args.dry_run

    print(f"repo   : {repo}")
    print(f"target : {target}")
    print(f"output : {out_root}")
    print(f"files  : {len(FILES)}")
    print(f"mode   : {'DRY RUN' if dry else 'write'}\n")

    dest_paths = {(out_root / rel).resolve(): rel for rel in FILES}
    new_basenames = {Path(rel).name for rel in FILES}

    # 1) back up clashing files (same basename elsewhere) and Developer files
    if not args.no_backup and not args.out:
        print("Backing up clashing / Developer files:")
        for f in list(iter_swift_files(repo)):
            fr = f.resolve()
            if fr in dest_paths:
                # same path as a generated file -> keep a copy, will be overwritten
                new_content = FILES[dest_paths[fr]]
                try:
                    if f.read_text(encoding="utf-8") != new_content:
                        copy_to_backup(repo, f, backup, dry)
                except Exception:
                    copy_to_backup(repo, f, backup, dry)
            elif f.name in new_basenames:
                move_to_backup(repo, f, backup, dry)
            elif re.search(r"developer", f.name, re.I):
                move_to_backup(repo, f, backup, dry)
        print()

    # 2) write files
    print("Writing files:")
    for rel, content in FILES.items():
        dest = out_root / rel
        try:
            shown = dest.relative_to(repo)
        except ValueError:
            shown = dest
        print(f"  + {shown}")
        if not dry:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(content, encoding="utf-8")
    print()

    # 3) Info.plist
    for plist in repo.rglob("Info.plist"):
        if _skip(plist):
            continue
        try:
            data = plistlib.loads(plist.read_bytes())
            if isinstance(data, dict) and "NSFaceIDUsageDescription" not in data:
                data["NSFaceIDUsageDescription"] = "Settings uses Face ID to unlock hidden apps."
                print(f"Info.plist: adding NSFaceIDUsageDescription -> {plist.relative_to(repo)}")
                if not dry:
                    plist.write_bytes(plistlib.dumps(data, sort_keys=False))
        except Exception as e:
            print(f"Info.plist: could not edit {plist}: {e}")

    # 4) remaining Developer references
    print("\nRemaining Developer references (remove manually):")
    found = False
    for f in iter_swift_files(repo):
        try:
            lines = f.read_text(encoding="utf-8", errors="ignore").splitlines()
        except Exception:
            continue
        for i, line in enumerate(lines, 1):
            if re.search(r"developer", line, re.I) and "App Developers" not in line and "app developers" not in line:
                print(f"  {f.relative_to(repo)}:{i}: {line.strip()[:110]}")
                found = True
    if not found:
        print("  none")

    # 5) project format hint
    pbx = next(repo.rglob("project.pbxproj"), None)
    if pbx and "PBXFileSystemSynchronizedRootGroup" in pbx.read_text(errors="ignore"):
        print("\nXcode: project uses synchronized folders - new files are picked up automatically.")
    else:
        print("\nXcode: drag the new folders into the project navigator and add them to the app target.")

    print("\nDone. Read README_iOS26_INTEGRATION.md for the final wiring steps.")


if __name__ == "__main__":
    main()
