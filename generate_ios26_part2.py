#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""generate_ios26_part2.py - Wi-Fi (iPadOS 26 layout), Mock Configuration panel,
Device Storage, Analytics fix. Run AFTER generate_ios26.py."""
import argparse, os, re, shutil, sys
from pathlib import Path

FILES = {}

# ====================================================================== MODELS
FILES["Models/SettingsStore.swift"] = r'''import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    // MARK: Apple Account
    var account: MockAppleAccount? { didSet { persist(account, key: "account") } }

    // MARK: Wi-Fi
    var wifiEnabled: Bool { didSet { UserDefaults.standard.set(wifiEnabled, forKey: "wifi.enabled") } }
    var wifiNetworks: [MockWiFiNetwork] { didSet { persist(wifiNetworks, key: "wifi.networks.v2") } }
    var knownNetworkSSIDs: Set<String> { didSet { persist(Array(knownNetworkSSIDs), key: "wifi.known.v2") } }
    var connectedSSID: String? { didSet { UserDefaults.standard.set(connectedSSID ?? "", forKey: "wifi.connected.v2") } }
    var askToJoin: String { didSet { UserDefaults.standard.set(askToJoin, forKey: "wifi.askToJoin") } }
    var autoJoinHotspot: String { didSet { UserDefaults.standard.set(autoJoinHotspot, forKey: "wifi.autoHotspot") } }

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
        wifiNetworks = SettingsStore.load([MockWiFiNetwork].self, key: "wifi.networks.v2") ?? MockWiFiNetwork.defaults
        knownNetworkSSIDs = Set(SettingsStore.load([String].self, key: "wifi.known.v2") ?? MockWiFiNetwork.defaultKnown)
        if let s = d.string(forKey: "wifi.connected.v2") { connectedSSID = s.isEmpty ? nil : s } else { connectedSSID = MockWiFiNetwork.defaultConnected }
        askToJoin = d.string(forKey: "wifi.askToJoin") ?? "Notify"
        autoJoinHotspot = d.string(forKey: "wifi.autoHotspot") ?? "Automatic"
        lowPowerMode = d.bool(forKey: "battery.lowPower")
        adaptivePower = d.bool(forKey: "battery.adaptive")
        batteryPercentage = d.object(forKey: "battery.percentage") as? Bool ?? true
        optimizedCharging = d.object(forKey: "battery.optimized") as? Bool ?? true
        chargeLimit = d.object(forKey: "battery.chargeLimit") as? Int ?? 80
        hiddenAppBundleIDs = Set(SettingsStore.load([String].self, key: "apps.hidden") ?? ["com.mock.ledger", "com.mock.notesplus"])
        requireAuthForHiddenApps = d.object(forKey: "apps.hidden.auth") as? Bool ?? true
        mockPasscode = d.string(forKey: "mock.passcode") ?? "000000"
    }

    func resetWiFi() {
        wifiNetworks = MockWiFiNetwork.defaults
        knownNetworkSSIDs = Set(MockWiFiNetwork.defaultKnown)
        connectedSSID = MockWiFiNetwork.defaultConnected
    }

    private func persist<T: Encodable>(_ value: T?, key: String) {
        UserDefaults.standard.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: key)
    }
    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }
}
'''

FILES["Models/WiFiModels.swift"] = r'''import SwiftUI
import Observation

struct MockWiFiNetwork: Identifiable, Hashable, Codable {
    var id: String { ssid }
    var ssid: String
    var security: Security
    var signal: Int              // 1...3
    var isHotspot: Bool
    var weakSecurity: Bool
    var password: String
    var ipAddress: String
    var router: String

    init(ssid: String, security: Security = .wpa2, signal: Int = 3, isHotspot: Bool = false,
         weakSecurity: Bool = false, password: String = "", ipAddress: String = "192.168.100.183", router: String = "192.168.100.1") {
        self.ssid = ssid; self.security = security; self.signal = signal; self.isHotspot = isHotspot
        self.weakSecurity = weakSecurity; self.password = password; self.ipAddress = ipAddress; self.router = router
    }

    enum Security: String, Codable, CaseIterable {
        case none = "None", wep = "WEP", wpa2 = "WPA2", wpa3 = "WPA3", enterprise = "WPA2 Enterprise"
        var isSecured: Bool { self != .none }
    }
    var securityLabel: String { weakSecurity ? "WPA/WPA2 (TKIP)" : security.rawValue }

    static let defaultConnected = "Mohammad-5G"
    static let defaultKnown = ["Mohammad-5G", "Mohammad-2.4G"]
    static let defaults: [MockWiFiNetwork] = [
        MockWiFiNetwork(ssid: "Mohammad-5G", security: .wpa2, signal: 3, weakSecurity: true, password: "mohammad12345"),
        MockWiFiNetwork(ssid: "Mohammad-2.4G", security: .wpa2, signal: 3, password: "mohammad12345", ipAddress: "192.168.100.184"),
        MockWiFiNetwork(ssid: "Irancell-TF-i60", security: .wpa2, signal: 2),
        MockWiFiNetwork(ssid: "Shatel_2F4A", security: .wpa2, signal: 1),
        MockWiFiNetwork(ssid: "Ali’s iPhone", security: .wpa2, signal: 2, isHotspot: true)
    ]
}

@MainActor
@Observable
final class WiFiEngine {
    static let shared = WiFiEngine()

    private(set) var visible: [MockWiFiNetwork] = []
    private(set) var scanning = false
    private(set) var joiningSSID: String?
    private var scanTask: Task<Void, Never>?
    let store = SettingsStore.shared

    var connectedNetwork: MockWiFiNetwork? { network(for: store.connectedSSID) }
    func network(for ssid: String?) -> MockWiFiNetwork? {
        guard let ssid else { return nil }
        return store.wifiNetworks.first { $0.ssid == ssid }
    }
    static func network(for ssid: String?) -> MockWiFiNetwork? { shared.network(for: ssid) }

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
        scanTask?.cancel(); scanTask = nil
        scanning = false; visible = []
    }

    enum JoinError: LocalizedError {
        case incorrectPassword
        var errorDescription: String? { "Incorrect password" }
    }

    func join(_ network: MockWiFiNetwork, password: String?) async throws {
        joiningSSID = network.ssid
        defer { joiningSSID = nil }
        let known = store.knownNetworkSSIDs.contains(network.ssid)
        if network.security.isSecured && !known {
            let pw = password ?? ""
            let expected = store.wifiNetworks.first { $0.ssid == network.ssid }?.password ?? ""
            let ok = pw.count >= 8 && (expected.isEmpty || pw == expected)
            if !ok {
                try? await Task.sleep(for: .seconds(0.8))
                throw JoinError.incorrectPassword
            }
        }
        try? await Task.sleep(for: .seconds(1.5))
        if !store.wifiNetworks.contains(where: { $0.ssid == network.ssid }) {
            var n = network; if !(password ?? "").isEmpty { n.password = password! }
            store.wifiNetworks.append(n)
        }
        store.knownNetworkSSIDs.insert(network.ssid)
        store.connectedSSID = network.ssid
        if !visible.contains(where: { $0.ssid == network.ssid }) { visible.append(network) }
    }

    func disconnect() { store.connectedSSID = nil }

    func forget(_ ssid: String) {
        store.knownNetworkSSIDs.remove(ssid)
        if store.connectedSSID == ssid { store.connectedSSID = nil }
    }
}
'''

FILES["Models/MockDeviceIdentity.swift"] = r'''import Foundation

/// Per-install fake identifiers + optional user overrides (editable in Mock Configuration).
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

    // overrides (nil = use real/default value)
    var modelName: String?
    var osVersion: String?
    var buildNumber: String?
    var capacity: String?
    var available: String?
    var songs: Int?
    var videos: Int?
    var photos: Int?

    static var stored: MockDeviceIdentity {
        if let data = UserDefaults.standard.data(forKey: "mock.identity"),
           let id = try? JSONDecoder().decode(MockDeviceIdentity.self, from: data) { return id }
        let id = generate()
        id.save()
        return id
    }

    func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(self), forKey: "mock.identity")
    }

    static func regenerate() -> MockDeviceIdentity {
        var n = generate()
        let old = stored
        n.modelName = old.modelName; n.osVersion = old.osVersion; n.buildNumber = old.buildNumber
        n.capacity = old.capacity; n.available = old.available
        n.save()
        return n
    }

    static func generate() -> MockDeviceIdentity {
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
            eid: digits(32), seid: hex(40),
            wifiAddress: mac(), bluetoothAddress: mac(),
            modemFirmware: "1.\(Int.random(in: 0...3))0.0\(Int.random(in: 1...9))",
            modelNumber: "M" + String(letters.randomElement()!) + String(letters.randomElement()!) + digits(2) + "LL/A",
            regulatoryModel: "A\(Int.random(in: 3200...3399))",
            iccid: "8901" + digits(16))
    }
}
'''

FILES["Models/MockAppleAccount.swift"] = r'''import UIKit

struct MockLinkedDevice: Codable, Hashable, Identifiable {
    enum Kind: String, Codable, CaseIterable {
        case iPhone = "iPhone", iPad = "iPad", mac = "Mac", watch = "Apple Watch", tv = "Apple TV", airPods = "AirPods", vision = "Apple Vision Pro"
        var symbol: String {
            switch self {
            case .iPhone: return "iphone"
            case .iPad: return "ipad"
            case .mac: return "macbook"
            case .watch: return "applewatch"
            case .tv: return "appletv"
            case .airPods: return "airpods.pro"
            case .vision: return "vision.pro"
            }
        }
    }
    var id: UUID
    var name: String
    var kind: Kind
    var model: String

    init(name: String, kind: Kind, model: String = "") {
        id = UUID(); self.name = name; self.kind = kind; self.model = model
    }

    static var defaults: [MockLinkedDevice] {
        let thisKind: Kind = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
        return [
            MockLinkedDevice(name: UIDevice.current.name, kind: thisKind, model: MockDevice.current.modelName),
            MockLinkedDevice(name: "Mohammad’s iPhone", kind: .iPhone, model: "iPhone 15 Pro"),
            MockLinkedDevice(name: "MacBook Pro", kind: .mac, model: "MacBook Pro 14”"),
            MockLinkedDevice(name: "Apple Watch", kind: .watch, model: "Apple Watch Series 9")
        ]
    }
}

struct MockAppleAccount: Codable, Equatable {
    var email: String
    var firstName: String
    var lastName: String
    var avatarData: Data?
    var signedInAt: Date
    var devices: [MockLinkedDevice]?

    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }
    var initials: String { String(firstName.prefix(1) + lastName.prefix(1)).uppercased() }
    var deviceList: [MockLinkedDevice] { devices ?? MockLinkedDevice.defaults }

    static func from(email: String) -> MockAppleAccount {
        let local = email.split(separator: "@").first.map(String.init) ?? "Apple User"
        let parts = local.split(whereSeparator: { ".-_".contains($0) }).map { $0.capitalized }
        return MockAppleAccount(email: email, firstName: parts.first ?? "Apple", lastName: parts.dropFirst().first ?? "User",
                                avatarData: nil, signedInAt: .now, devices: nil)
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

@Observable
final class AnalyticsStore {
    static let shared = AnalyticsStore()
    private(set) var files: [AnalyticsFile] = []

    let directory: URL = {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("DiagnosticReports", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        seed(days: 7, onlyIfEmpty: true)
        reload()
    }

    func reload() {
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        files = urls.filter { !$0.lastPathComponent.hasPrefix(".") }
            .map(AnalyticsFile.init)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func contents(of file: AnalyticsFile) -> String {
        (try? String(contentsOf: file.url, encoding: .utf8)) ?? ""
    }

    func deleteAll() {
        for f in files { try? FileManager.default.removeItem(at: f.url) }
        reload()
    }

    func forceSeed() { seed(days: 7, onlyIfEmpty: false); reload() }

    private func seed(days: Int, onlyIfEmpty: Bool) {
        let existing = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        if onlyIfEmpty && !existing.isEmpty {
            let date = Date.now
            write(AnalyticsFileTemplates.analytics(date: date))
            write(AnalyticsFileTemplates.logAggregated(date: date))
            return
        }
        for d in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
            write(AnalyticsFileTemplates.analytics(date: date))
            write(AnalyticsFileTemplates.logAggregated(date: date))
            if d % 2 == 0 { write(AnalyticsFileTemplates.jetsam(date: date)) }
            if d % 3 == 0 { write(AnalyticsFileTemplates.wifiLQM(date: date)) }
            if d == 0 {
                write(AnalyticsFileTemplates.stacks(date: date))
                write(AnalyticsFileTemplates.awdd(date: date))
                write(AnalyticsFileTemplates.logPower(date: date))
            }
        }
    }

    private func write(_ f: (name: String, body: String)) {
        let url = directory.appendingPathComponent(f.name)
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        try? f.body.write(to: url, atomically: true, encoding: .utf8)
    }
}
'''

# ====================================================================== ABOUT + CONFIG
FILES["Views/General/AboutView.swift"] = r'''import SwiftUI

struct AboutView: View {
    @AppStorage("device.name") private var name = UIDevice.current.name
    @State private var identity = MockDeviceIdentity.stored
    @State private var showRegulatoryModel = false
    @State private var showConfig = false
    private let device = MockDevice.current

    var body: some View {
        List {
            Section {
                NavigationLink { DeviceNameView(name: $name) } label: { LabeledContent("Name", value: name) }
            }
            Section {
                NavigationLink { IOSVersionView(identity: identity) } label: {
                    LabeledContent("\(device.systemName) Version", value: identity.osVersion ?? device.systemVersion)
                }
                LabeledContent("Model Name", value: identity.modelName ?? device.modelName)
                    .contextMenu { configButton }
                LabeledContent("Model Number", value: showRegulatoryModel ? identity.regulatoryModel : identity.modelNumber)
                    .contentShape(Rectangle())
                    .onTapGesture { showRegulatoryModel.toggle() }
                LabeledContent("Serial Number", value: identity.serialNumber)
                    .contextMenu {
                        Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.serialNumber }
                        configButton
                    }
                NavigationLink { CoverageView() } label: { LabeledContent("Coverage", value: "Limited Warranty") }
            }
            Section {
                LabeledContent("Songs", value: "\(identity.songs ?? 0)")
                LabeledContent("Videos", value: "\(identity.videos ?? 12)")
                LabeledContent("Photos", value: (identity.photos ?? 3482).formatted())
                LabeledContent("Applications", value: "\(MockAppCatalog.all.count)")
                LabeledContent("Capacity", value: identity.capacity ?? "256 GB")
                LabeledContent("Available", value: identity.available ?? "118.42 GB")
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
                        VStack(alignment: .leading, spacing: 2) { Text("Primary"); Text("No SIM").font(.footnote).foregroundStyle(.secondary) }
                    }
                }
            }
            Section { NavigationLink("Certificate Trust Settings") { CertificateTrustView() } }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { identity = .stored }
        .sheet(isPresented: $showConfig, onDismiss: { identity = .stored }) { NavigationStack { MockConfigView() } }
    }

    private var configButton: some View {
        Button("Mock Configuration…", systemImage: "slider.horizontal.3") { showConfig = true }
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
                    Button { name = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }.buttonStyle(.borderless)
                }
            }
        }
        .navigationTitle("Name").navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }
}

struct IOSVersionView: View {
    let identity: MockDeviceIdentity
    private let d = MockDevice.current
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(d.systemName) \(identity.osVersion ?? d.systemVersion)").font(.headline)
                    Text("Build \(identity.buildNumber ?? d.buildNumber)").font(.footnote).foregroundStyle(.secondary)
                }
            } footer: {
                Text("\(d.systemName) \(identity.osVersion ?? d.systemVersion) brings a beautiful new design with Liquid Glass, more expressive experiences across your apps, and intelligent features that make everyday tasks easier.")
            }
        }
        .navigationTitle("\(d.systemName) Version").navigationBarTitleDisplayMode(.inline)
    }
}

struct CoverageView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Limited Warranty", value: "Active")
                LabeledContent("Expires", value: Date.now.addingTimeInterval(200 * 86_400).formatted(date: .abbreviated, time: .omitted))
            } footer: { Text("Your device is covered by Apple’s Limited Warranty for hardware repairs and service.") }
            Section { Link("Learn About AppleCare+", destination: URL(string: "https://www.apple.com/support/products/")!) }
        }
        .navigationTitle("Coverage").navigationBarTitleDisplayMode(.inline)
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
        .navigationTitle("Primary").navigationBarTitleDisplayMode(.inline)
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
            Section { Toggle("Enable Full Trust for Root Certificates", isOn: $fullTrust) } footer: {
                Text("No certificates have been installed on this device.")
            }
        }
        .navigationTitle("Certificate Trust Settings").navigationBarTitleDisplayMode(.inline)
    }
}
'''

FILES["Views/General/MockConfigView.swift"] = r'''import SwiftUI
import PhotosUI

/// Hidden panel: About -> long-press "Serial Number" -> "Mock Configuration…"
struct MockConfigView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("device.name") private var deviceName = UIDevice.current.name

    @State private var identity = MockDeviceIdentity.stored
    @State private var loaded = false
    @State private var signedIn = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var avatarData: Data?
    @State private var photoItem: PhotosPickerItem?
    @State private var devices: [MockLinkedDevice] = []
    @State private var newDeviceName = ""
    @State private var newDeviceKind: MockLinkedDevice.Kind = .iPhone
    @State private var osVersion = ""
    @State private var build = ""
    @State private var modelName = ""
    @State private var capacity = ""
    @State private var available = ""
    @State private var confirmReset = false

    var body: some View {
        @Bindable var store = store
        List {
            // MARK: Apple Account
            Section("Apple Account") {
                Toggle("Signed In", isOn: $signedIn)
                if signedIn {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    HStack {
                        PhotosPicker("Choose Photo", selection: $photoItem, matching: .images)
                        Spacer()
                        if let avatarData, let img = UIImage(data: avatarData) {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                        }
                    }
                    if avatarData != nil { Button("Remove Photo", role: .destructive) { avatarData = nil; photoItem = nil } }
                }
            }
            if signedIn {
                Section {
                    ForEach(devices) { d in
                        HStack(spacing: 12) {
                            Image(systemName: d.kind.symbol).frame(width: 24)
                            VStack(alignment: .leading) {
                                Text(d.name)
                                Text(d.model.isEmpty ? d.kind.rawValue : d.model).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { devices.remove(atOffsets: $0) }
                    HStack {
                        TextField("Device name", text: $newDeviceName)
                        Picker("", selection: $newDeviceKind) { ForEach(MockLinkedDevice.Kind.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.labelsHidden()
                        Button { devices.append(MockLinkedDevice(name: newDeviceName, kind: newDeviceKind)); newDeviceName = "" } label: {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.green)
                        }.buttonStyle(.borderless).disabled(newDeviceName.isEmpty)
                    }
                } header: { Text("Devices") } footer: { Text("Shown in Apple Account → Devices.") }
            }

            // MARK: Device
            Section("Device") {
                TextField("Name", text: $deviceName)
                TextField("Model Name (e.g. iPad Pro 13-inch (M4))", text: $modelName)
                TextField("Model Number", text: $identity.modelNumber)
                TextField("Regulatory Model (A####)", text: $identity.regulatoryModel)
                TextField("Serial Number", text: $identity.serialNumber).textInputAutocapitalization(.characters)
                TextField("iOS Version (e.g. 26.0)", text: $osVersion)
                TextField("Build (e.g. 23A340)", text: $build)
                TextField("Capacity (e.g. 256 GB)", text: $capacity)
                TextField("Available (e.g. 118.42 GB)", text: $available)
                TextField("Wi-Fi Address", text: $identity.wifiAddress)
                TextField("Bluetooth Address", text: $identity.bluetoothAddress)
                TextField("IMEI", text: $identity.imei)
                Button("Regenerate Identifiers") { identity = MockDeviceIdentity.regenerate() }
            }

            // MARK: Wi-Fi
            Section {
                ForEach(store.wifiNetworks) { n in
                    NavigationLink {
                        WiFiNetworkEditor(network: n, known: store.knownNetworkSSIDs.contains(n.ssid), connected: store.connectedSSID == n.ssid)
                    } label: {
                        HStack {
                            Text(n.ssid)
                            Spacer()
                            if store.connectedSSID == n.ssid { Text("Connected").font(.footnote).foregroundStyle(.green) }
                            else if store.knownNetworkSSIDs.contains(n.ssid) { Text("Known").font(.footnote).foregroundStyle(.secondary) }
                        }
                    }
                }
                .onDelete { idx in
                    for i in idx { WiFiEngine.shared.forget(store.wifiNetworks[i].ssid) }
                    store.wifiNetworks.remove(atOffsets: idx)
                }
                Button("Add Network") { store.wifiNetworks.append(MockWiFiNetwork(ssid: "Network \(store.wifiNetworks.count + 1)")) }
                Button("Reset Wi-Fi Networks") { store.resetWiFi() }
            } header: { Text("Wi-Fi Networks") } footer: { Text("Swipe to delete. Tap a network to edit its name, password, security and state.") }

            Section {
                Toggle("Hidden Apps require Face ID / passcode", isOn: $store.requireAuthForHiddenApps)
                LabeledContent("Mock passcode", value: store.mockPasscode)
            }
            Section {
                Button("Reset All Mock Data", role: .destructive) { confirmReset = true }
            }
        }
        .navigationTitle("Mock Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Done") { save(); dismiss() }.fontWeight(.semibold) }
        }
        .onAppear { if !loaded { load(); loaded = true } }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data),
                   let jpeg = img.preparingThumbnail(of: CGSize(width: 400, height: 400))?.jpegData(compressionQuality: 0.85) {
                    avatarData = jpeg
                }
            }
        }
        .confirmationDialog("Reset all mock data?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) {
                let d = UserDefaults.standard
                for k in d.dictionaryRepresentation().keys { d.removeObject(forKey: k) }
                store.account = nil
                store.resetWiFi()
                identity = MockDeviceIdentity.regenerate()
                load()
            }
        }
    }

    private func load() {
        identity = .stored
        modelName = identity.modelName ?? ""
        osVersion = identity.osVersion ?? ""
        build = identity.buildNumber ?? ""
        capacity = identity.capacity ?? ""
        available = identity.available ?? ""
        if let a = store.account {
            signedIn = true; firstName = a.firstName; lastName = a.lastName; email = a.email
            avatarData = a.avatarData; devices = a.deviceList
        } else {
            signedIn = false; firstName = "Mohammad"; lastName = ""; email = "mohammad@icloud.com"
            avatarData = nil; devices = MockLinkedDevice.defaults
        }
    }

    private func save() {
        func nilIfEmpty(_ s: String) -> String? { s.trimmingCharacters(in: .whitespaces).isEmpty ? nil : s }
        identity.modelName = nilIfEmpty(modelName)
        identity.osVersion = nilIfEmpty(osVersion)
        identity.buildNumber = nilIfEmpty(build)
        identity.capacity = nilIfEmpty(capacity)
        identity.available = nilIfEmpty(available)
        identity.save()
        if signedIn {
            store.account = MockAppleAccount(email: email, firstName: firstName, lastName: lastName,
                                             avatarData: avatarData, signedInAt: store.account?.signedInAt ?? .now, devices: devices)
        } else {
            store.account = nil
        }
    }
}

struct WiFiNetworkEditor: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let originalSSID: String
    @State private var net: MockWiFiNetwork
    @State private var known: Bool
    @State private var connected: Bool

    init(network: MockWiFiNetwork, known: Bool, connected: Bool) {
        originalSSID = network.ssid
        _net = State(initialValue: network)
        _known = State(initialValue: known)
        _connected = State(initialValue: connected)
    }

    var body: some View {
        List {
            Section("Network") {
                TextField("Name (SSID)", text: $net.ssid)
                Picker("Security", selection: $net.security) { ForEach(MockWiFiNetwork.Security.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
                Toggle("Weak Security (TKIP)", isOn: $net.weakSecurity)
                TextField("Password", text: $net.password)
                Stepper("Signal: \(net.signal)/3", value: $net.signal, in: 1...3)
                Toggle("Personal Hotspot", isOn: $net.isHotspot)
            }
            Section("IPv4") {
                TextField("IP Address", text: $net.ipAddress)
                TextField("Router", text: $net.router)
            }
            Section("State") {
                Toggle("Known (My Networks)", isOn: $known)
                Toggle("Connected", isOn: $connected).onChange(of: connected) { _, on in if on { known = true } }
            }
        }
        .navigationTitle(originalSSID)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } } }
    }

    private func save() {
        if let i = store.wifiNetworks.firstIndex(where: { $0.ssid == originalSSID }) { store.wifiNetworks[i] = net }
        store.knownNetworkSSIDs.remove(originalSSID)
        if known { store.knownNetworkSSIDs.insert(net.ssid) }
        if connected { store.connectedSSID = net.ssid }
        else if store.connectedSSID == originalSSID { store.connectedSSID = nil }
    }
}
'''

FILES["Views/General/DeviceStorageView.swift"] = r'''import SwiftUI
import Observation

@MainActor
@Observable
final class StorageDataProvider {
    static let shared = StorageDataProvider()

    struct Category: Identifiable { let id = UUID(); let name: String; let gb: Double; let color: Color }
    struct AppEntry: Identifiable {
        var id: String { app.bundleID }
        let app: MockApp
        let appGB: Double
        let dataGB: Double
        let lastUsed: Date
        var total: Double { appGB + dataGB }
    }

    var totalGB: Double = 256
    var availableGB: Double = 118.42
    var categories: [Category] = []
    var apps: [AppEntry] = []
    var usedGB: Double { max(0, totalGB - availableGB) }

    init() { reload() }

    func reload() {
        let id = MockDeviceIdentity.stored
        totalGB = Self.parseGB(id.capacity) ?? 256
        availableGB = min(totalGB, Self.parseGB(id.available) ?? 118.42)
        let iosGB = 12.1
        let rest = max(0, usedGB - iosGB)
        categories = [
            Category(name: "Apps", gb: rest * 0.42, color: .red),
            Category(name: "Photos", gb: rest * 0.37, color: .yellow),
            Category(name: "Media", gb: rest * 0.05, color: .purple),
            Category(name: "iOS", gb: iosGB, color: .gray),
            Category(name: "System Data", gb: rest * 0.16, color: Color(.systemGray3))
        ]
        var rng = SeededGenerator(seed: 4242)
        let weights = MockAppCatalog.all.map { _ in Double.random(in: 0.2...3.0, using: &rng) }
        let sum = weights.reduce(0, +)
        let appsGB = categories[0].gb
        apps = zip(MockAppCatalog.all, weights).map { app, w in
            let total = appsGB * w / max(sum, 0.001)
            let ratio = Double.random(in: 0.2...0.7, using: &rng)
            return AppEntry(app: app, appGB: total * ratio, dataGB: total * (1 - ratio), lastUsed: Date.daysAgo(Int.random(in: 0...60, using: &rng)))
        }.sorted { $0.total > $1.total }
    }

    func remove(_ id: String) { apps.removeAll { $0.id == id } }

    private static func parseGB(_ s: String?) -> Double? {
        guard let s else { return nil }
        let digits = s.replacingOccurrences(of: ",", with: ".").filter { "0123456789.".contains($0) }
        guard let v = Double(digits) else { return nil }
        return s.uppercased().contains("TB") ? v * 1024 : v
    }
}

func storageLabel(_ gb: Double) -> String {
    if gb >= 1 { return String(format: "%.1f GB", gb) }
    let mb = gb * 1024
    return mb >= 1 ? String(format: "%.0f MB", mb) : String(format: "%.0f KB", mb * 1024)
}

struct DeviceStorageView: View {
    @State private var data = StorageDataProvider.shared
    @State private var offloadEnabled = false
    private let deviceType = MockDevice.current.deviceTypeName

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(deviceType).font(.title3.weight(.semibold))
                        Spacer()
                        Text("\(storageLabel(data.usedGB)) of \(Int(data.totalGB)) GB Used").font(.subheadline).foregroundStyle(.secondary)
                    }
                    GeometryReader { g in
                        HStack(spacing: 1.5) {
                            ForEach(data.categories) { c in
                                Rectangle().fill(c.color).frame(width: max(1, g.size.width * c.gb / max(data.totalGB, 1)))
                            }
                            Spacer(minLength: 0)
                        }
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 14)
                    LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 6) {
                        ForEach(data.categories) { c in
                            HStack(spacing: 5) {
                                RoundedRectangle(cornerRadius: 2).fill(c.color).frame(width: 9, height: 9)
                                Text(c.name).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Recommendations") {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Offload Unused Apps")
                        Text("Automatically offload unused apps when you’re low on storage. Your documents and data will be saved.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if offloadEnabled { Text("Enabled").font(.subheadline).foregroundStyle(.secondary) }
                    else { Button("Enable") { withAnimation { offloadEnabled = true } }.font(.subheadline.weight(.semibold)) }
                }
                .padding(.vertical, 2)
            }

            Section {
                ForEach(data.apps) { e in
                    NavigationLink { StorageAppDetailView(entry: e) } label: {
                        HStack(spacing: 12) {
                            AppIconView(app: e.app, side: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.app.name)
                                Text(lastUsedText(e.lastUsed)).font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(storageLabel(e.total)).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                LabeledContent("\(MockDevice.current.systemName)", value: storageLabel(data.categories.first { $0.name == "iOS" }?.gb ?? 12.1))
                LabeledContent("System Data", value: storageLabel(data.categories.last?.gb ?? 0))
            } footer: {
                Text("System Data includes caches, logs and other resources currently in use by the system. This value fluctuates according to system needs.")
            }
        }
        .navigationTitle("\(deviceType) Storage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { data.reload() }
    }

    private func lastUsedText(_ d: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: d, to: .now).day ?? 0
        if days == 0 { return "Last Used: Today" }
        if days == 1 { return "Last Used: Yesterday" }
        if days < 14 { return "Last Used: \(days) days ago" }
        return "Last Used: \(d.formatted(.dateTime.month(.abbreviated).day()))"
    }
}

struct StorageAppDetailView: View {
    let entry: StorageDataProvider.AppEntry
    @State private var data = StorageDataProvider.shared
    @Environment(\.dismiss) private var dismiss
    @State private var confirmOffload = false
    @State private var confirmDelete = false
    @State private var offloaded = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    AppIconView(app: entry.app, side: 64)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.app.name).font(.title3.weight(.semibold))
                        Text(entry.app.category.rawValue).font(.footnote).foregroundStyle(.secondary)
                        Text("Version 26.\(abs(entry.app.bundleID.hashValue) % 9).\(abs(entry.app.bundleID.hashValue) % 5)").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                LabeledContent("App Size", value: offloaded ? "0 KB" : storageLabel(entry.appGB))
                LabeledContent("Documents & Data", value: storageLabel(entry.dataGB))
            }
            Section {
                if offloaded { Button("Reinstall App") { withAnimation { offloaded = false } } }
                else { Button("Offload App") { confirmOffload = true } }
            } footer: {
                Text("This will free up storage used by the app, but keep its documents and data. Reinstalling the app will place back your data if the app is still available in the App Store.")
            }
            Section {
                Button("Delete App", role: .destructive) { confirmDelete = true }
            } footer: {
                Text("This will delete the app and all related data from this \(MockDevice.current.deviceTypeName). This action can’t be undone.")
            }
        }
        .navigationTitle(entry.app.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Offload “\(entry.app.name)”?", isPresented: $confirmOffload, titleVisibility: .visible) {
            Button("Offload App") { withAnimation { offloaded = true } }
        }
        .confirmationDialog("Delete “\(entry.app.name)”?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete App", role: .destructive) { data.remove(entry.id); dismiss() }
        } message: { Text("Deleting this app will also delete its data.") }
    }
}
'''

# ====================================================================== APPLE ACCOUNT
FILES["Views/Apple Account/AppleAccountView.swift"] = r'''import SwiftUI
import PhotosUI

struct AppleAccountView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var confirmSignOut = false

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
                Section("Devices") {
                    ForEach(account.deviceList) { d in
                        NavigationLink { LinkedDeviceDetailView(device: d) } label: {
                            HStack(spacing: 12) {
                                Image(systemName: d.kind.symbol).font(.title2).frame(width: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(d.name)
                                    Text(d.name == UIDevice.current.name ? "This \(MockDevice.current.deviceTypeName)" : (d.model.isEmpty ? d.kind.rawValue : d.model))
                                        .font(.footnote).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                Section {
                    Button("Sign Out", role: .destructive) { confirmSignOut = true }.frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Apple Account")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data),
                       let jpeg = img.preparingThumbnail(of: CGSize(width: 400, height: 400))?.jpegData(compressionQuality: 0.85) {
                        store.account?.avatarData = jpeg
                    }
                }
            }
            .confirmationDialog("Sign Out of Apple Account?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { store.account = nil; dismiss() }
            } message: { Text("Signing out will remove iCloud data and turn off Find My for this device.") }
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

struct LinkedDeviceDetailView: View {
    let device: MockLinkedDevice
    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: device.kind.symbol).font(.system(size: 56))
                    Text(device.name).font(.title3.weight(.semibold))
                    Text(device.model.isEmpty ? device.kind.rawValue : device.model).font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).listRowBackground(Color.clear)
            }
            Section("Device Info") {
                LabeledContent("Model", value: device.model.isEmpty ? device.kind.rawValue : device.model)
                LabeledContent("Version", value: device.kind == .mac ? "macOS 26" : device.kind == .watch ? "watchOS 26" : "iOS 26")
                LabeledContent("Find My", value: "On")
            }
            Section { Button("Remove from Account", role: .destructive) {} }
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

# ====================================================================== WI-FI
FILES["Views/Radios/Network/WiFiView.swift"] = r'''import SwiftUI

struct WiFiView: View {
    @Environment(SettingsStore.self) private var store
    @State private var engine = WiFiEngine.shared
    @State private var joining: MockWiFiNetwork?
    @State private var detail: MockWiFiNetwork?
    private let isPad = MockDevice.current.isPad

    private var others: [MockWiFiNetwork] { engine.visible.filter { !store.knownNetworkSSIDs.contains($0.ssid) } }
    private var known: [MockWiFiNetwork] { engine.visible.filter { store.knownNetworkSSIDs.contains($0.ssid) && $0.ssid != store.connectedSSID } }

    var body: some View {
        @Bindable var store = store
        List {
            Section {
                if isPad { WiFiPlacard().listRowSeparator(.hidden, edges: .top) }
                Toggle("Wi-Fi", isOn: $store.wifiEnabled)
                if store.wifiEnabled, let net = engine.connectedNetwork {
                    NetworkRow(network: net, state: .connected, onInfo: { detail = net })
                }
            } footer: {
                if !store.wifiEnabled { Text("Turn on Wi-Fi to see available networks.") }
            }

            if store.wifiEnabled {
                if !known.isEmpty {
                    Section("My Networks") {
                        ForEach(known) { n in
                            NetworkRow(network: n, state: engine.joiningSSID == n.ssid ? .joining : .idle, onTap: { connectKnown(n) }, onInfo: { detail = n })
                        }
                    }
                }
                Section {
                    ForEach(others) { n in
                        NetworkRow(network: n, state: engine.joiningSSID == n.ssid ? .joining : .idle, onTap: { joining = n }, onInfo: { detail = n })
                    }
                    NavigationLink("Other…") { OtherNetworkView() }
                } header: {
                    HStack(spacing: 8) {
                        Text("Networks")
                        if engine.scanning { ProgressView().controlSize(.mini) }
                    }
                }
                Section {
                    NavigationLink { AskToJoinPickerView() } label: { LabeledContent("Ask to Join Networks", value: store.askToJoin) }
                } footer: { Text(askFooter) }
                Section {
                    NavigationLink { AutoJoinHotspotPickerView() } label: { LabeledContent("Auto-Join Hotspot", value: store.autoJoinHotspot) }
                } footer: { Text("Allow this device to automatically discover nearby personal hotspots when no Wi-Fi network is available.") }
            }
        }
        .navigationTitle(isPad ? "" : "Wi-Fi")
        .navigationBarTitleDisplayMode(isPad ? .inline : .large)
        .toolbar { if store.wifiEnabled { EditButton() } }
        .sheet(item: $joining) { JoinNetworkSheet(network: $0, engine: engine) }
        .navigationDestination(item: $detail) { NetworkDetailView(network: $0) }
        .task { engine.startScanning() }
        .onChange(of: store.wifiEnabled) { _, on in on ? engine.startScanning() : engine.stopScanning() }
        .onDisappear { engine.stopScanning() }
    }

    private var askFooter: String {
        switch store.askToJoin {
        case "Off": return "Known networks will be joined automatically. If no known networks are available, you will have to manually select a network."
        case "Ask": return "Known networks will be joined automatically. If no known networks are available, you will be asked before joining a new network."
        default: return "Known networks will be joined automatically. If no known networks are available, you will be notified of available networks."
        }
    }

    private func connectKnown(_ n: MockWiFiNetwork) {
        Task { try? await engine.join(n, password: n.password) }
    }
}

struct WiFiPlacard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .overlay(Image(systemName: "wifi").font(.system(size: 32, weight: .medium)).foregroundStyle(.white))
            Text("Wi-Fi").font(.title2.bold())
            (Text("Connect to Wi-Fi, view available networks, and manage settings for joining networks and nearby hotspots.").foregroundColor(.secondary)
             + Text(" [Learn more...](https://support.apple.com/guide/ipad/connect-to-wi-fi-ipad4f1b3e2b/ipados)"))
                .font(.callout)
        }
        .padding(.vertical, 10)
    }
}
'''

FILES["Views/Radios/Network/NetworkRow.swift"] = r'''import SwiftUI

struct NetworkRow: View {
    enum RowState { case idle, connected, joining }
    let network: MockWiFiNetwork
    let state: RowState
    var onTap: () -> Void = {}
    var onInfo: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                if state == .connected { Image(systemName: "checkmark").font(.body.weight(.semibold)).foregroundStyle(.blue) }
                else if state == .joining { ProgressView().controlSize(.small) }
            }
            .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(network.ssid)
                if state == .connected && network.weakSecurity {
                    Text("Weak Security").font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 14) {
                if network.security.isSecured { Image(systemName: "lock.fill").font(.subheadline) }
                Image(systemName: network.isHotspot ? "personalhotspot" : "wifi", variableValue: Double(network.signal) / 3).font(.subheadline)
                Button(action: onInfo) { Image(systemName: "info.circle").font(.title3).foregroundStyle(.blue) }
                    .buttonStyle(.borderless)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if state == .idle { onTap() } }
    }
}
'''

FILES["Views/Radios/Network/NetworkDetailView.swift"] = r'''import SwiftUI

struct NetworkDetailView: View {
    let network: MockWiFiNetwork
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmForget = false
    @State private var showPassword = false
    @State private var showPasscode = false
    @AppStorage private var autoJoin: Bool
    @AppStorage private var lowData: Bool
    @AppStorage private var privateAddress: String
    @AppStorage private var limitIP: Bool
    @AppStorage private var configureIP: String
    @AppStorage private var configureDNS: String
    @AppStorage private var proxy: String

    init(network: MockWiFiNetwork) {
        self.network = network
        let k = "wifi." + network.ssid.replacingOccurrences(of: " ", with: "_")
        _autoJoin = AppStorage(wrappedValue: true, k + ".autoJoin")
        _lowData = AppStorage(wrappedValue: false, k + ".lowData")
        _privateAddress = AppStorage(wrappedValue: "Rotating", k + ".private")
        _limitIP = AppStorage(wrappedValue: true, k + ".limitIP")
        _configureIP = AppStorage(wrappedValue: "Automatic", k + ".ip")
        _configureDNS = AppStorage(wrappedValue: "Automatic", k + ".dns")
        _proxy = AppStorage(wrappedValue: "Off", k + ".proxy")
    }

    private var isKnown: Bool { store.knownNetworkSSIDs.contains(network.ssid) }
    private var isConnected: Bool { store.connectedSSID == network.ssid }
    private let deviceType = MockDevice.current.deviceTypeName

    private var wifiAddress: String {
        switch privateAddress {
        case "Off": return MockDeviceIdentity.stored.wifiAddress
        case "Fixed": return Self.derivedMAC(network.ssid)
        default:
            let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
            return Self.derivedMAC(network.ssid + "-\(day)")
        }
    }

    var body: some View {
        List {
            if network.weakSecurity {
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Weak Security").font(.headline)
                        Text("WPA/WPA2 (TKIP) is not considered secure.")
                        Text("If this is your Wi-Fi network, configure the router to use WPA2 (AES) or WPA3 security type.")
                    }
                    .padding(.vertical, 6)
                } footer: {
                    Link("Learn more about recommended settings for Wi-Fi...", destination: URL(string: "https://support.apple.com/HT202068")!)
                        .font(.footnote).foregroundStyle(.blue)
                }
            }

            if isKnown {
                Section { Button("Forget This Network") { confirmForget = true } }
            }

            Section {
                Toggle("Auto-Join", isOn: $autoJoin)
                if isKnown && network.security.isSecured {
                    HStack {
                        Text("Password")
                        Spacer()
                        Text(showPassword ? network.password : String(repeating: "•", count: 13)).foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Task { await togglePassword() } }
                    .contextMenu { if showPassword { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = network.password } } }
                }
            }

            Section { Toggle("Low Data Mode", isOn: $lowData) } footer: {
                Text("Low Data Mode helps reduce your \(deviceType) data usage over your cellular network or specific Wi-Fi networks you select. When Low Data Mode is turned on, automatic updates and background tasks, such as Photos syncing, are paused.")
            }

            Section {
                NavigationLink { PrivateAddressPickerView(selection: $privateAddress) } label: { LabeledContent("Private Wi-Fi Address", value: privateAddress) }
                LabeledContent("Wi-Fi Address", value: wifiAddress)
            } footer: {
                Text(privateAddress == "Off"
                     ? "Using a private address helps reduce tracking of your \(deviceType) across different Wi-Fi networks."
                     : "Wi-Fi networks and devices can track other nearby Wi-Fi devices by their Wi-Fi address, even on secure networks. A \(privateAddress.lowercased()) private address reduces tracking by \(privateAddress == "Rotating" ? "periodically changing" : "using a different") this device’s Wi-Fi address on this network.")
            }

            Section { Toggle("Limit IP Address Tracking", isOn: $limitIP) } footer: {
                Text("Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari.")
            }

            Section("IPv4 Address") {
                NavigationLink { OptionPickerView(title: "Configure IPv4", options: ["Automatic", "Manual", "BootP"], selection: $configureIP) } label: {
                    LabeledContent("Configure IP", value: configureIP)
                }
                if isConnected {
                    LabeledContent("IP Address", value: network.ipAddress)
                    LabeledContent("Subnet Mask", value: "255.255.255.0")
                    LabeledContent("Router", value: network.router)
                }
            }
            Section("DNS") {
                NavigationLink { OptionPickerView(title: "Configure DNS", options: ["Automatic", "Manual"], selection: $configureDNS) } label: {
                    LabeledContent("Configure DNS", value: configureDNS)
                }
            }
            Section("HTTP Proxy") {
                NavigationLink { OptionPickerView(title: "Configure Proxy", options: ["Off", "Manual", "Automatic"], selection: $proxy) } label: {
                    LabeledContent("Configure Proxy", value: proxy)
                }
            }
        }
        .navigationTitle(network.ssid)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Forget Wi-Fi Network “\(network.ssid)”?", isPresented: $confirmForget, titleVisibility: .visible) {
            Button("Forget", role: .destructive) { WiFiEngine.shared.forget(network.ssid); dismiss() }
        } message: { Text("Your \(deviceType) will no longer join this Wi-Fi network.") }
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Password") { ok in showPasscode = false; if ok { showPassword = true } }
        }
    }

    private func togglePassword() async {
        if showPassword { showPassword = false; return }
        switch await HiddenAppsAuth.authenticate(reason: "View Wi-Fi password") {
        case .some(true): showPassword = true
        case .some(false): break
        case .none: showPasscode = true
        }
    }

    private static func derivedMAC(_ seed: String) -> String {
        var h: UInt64 = 1469598103934665603
        for b in seed.utf8 { h ^= UInt64(b); h = h &* 1099511628211 }
        var rng = SeededGenerator(seed: h)
        var bytes = (0..<6).map { _ in UInt8.random(in: 0...255, using: &rng) }
        bytes[0] = (bytes[0] | 0x02) & 0xFE
        return bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
    }
}
'''

FILES["Views/Radios/Network/WiFiOptionPickers.swift"] = r'''import SwiftUI

struct OptionPickerView: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    var footers: [String: String] = [:]

    var body: some View {
        List {
            Section {
                ForEach(options, id: \.self) { o in
                    Button { selection = o } label: {
                        HStack {
                            Text(o).foregroundStyle(.primary)
                            Spacer()
                            if o == selection { Image(systemName: "checkmark").fontWeight(.semibold).foregroundStyle(.blue) }
                        }
                    }
                }
            } footer: { if let f = footers[selection] { Text(f) } }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AskToJoinPickerView: View {
    @Environment(SettingsStore.self) private var store
    var body: some View {
        @Bindable var store = store
        OptionPickerView(title: "Ask to Join Networks", options: ["Off", "Notify", "Ask"], selection: $store.askToJoin, footers: [
            "Off": "Known networks will be joined automatically. If no known networks are available, you will have to manually select a network.",
            "Notify": "Known networks will be joined automatically. If no known networks are available, you will be notified of available networks.",
            "Ask": "Known networks will be joined automatically. If no known networks are available, you will be asked before joining a new network."
        ])
    }
}

struct AutoJoinHotspotPickerView: View {
    @Environment(SettingsStore.self) private var store
    var body: some View {
        @Bindable var store = store
        OptionPickerView(title: "Auto-Join Hotspot", options: ["Never", "Ask to Join", "Automatic"], selection: $store.autoJoinHotspot, footers: [
            "Never": "Your \(MockDevice.current.deviceTypeName) will not automatically join nearby personal hotspots.",
            "Ask to Join": "You will be asked before joining a nearby personal hotspot when no Wi-Fi network is available.",
            "Automatic": "Allow this device to automatically discover nearby personal hotspots when no Wi-Fi network is available."
        ])
    }
}

struct PrivateAddressPickerView: View {
    @Binding var selection: String
    var body: some View {
        OptionPickerView(title: "Private Wi-Fi Address", options: ["Off", "Fixed", "Rotating"], selection: $selection, footers: [
            "Off": "Your \(MockDevice.current.deviceTypeName) will use its real Wi-Fi address on this network. Turning this off may reduce privacy.",
            "Fixed": "A fixed private address stays the same on this network, which some networks require for access.",
            "Rotating": "A rotating private address changes periodically to reduce tracking of your \(MockDevice.current.deviceTypeName) on this network."
        ])
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
            if security != "None" { Section("Password") { SecureField("Password", text: $password) } }
        }
        .navigationTitle("Other Network")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if joining { ProgressView() } else {
                    Button("Join") {
                        joining = true
                        Task {
                            let sec: MockWiFiNetwork.Security = security == "None" ? .none : security == "WEP" ? .wep : security == "WPA3" ? .wpa3 : security == "WPA2 Enterprise" ? .enterprise : .wpa2
                            let net = MockWiFiNetwork(ssid: name, security: sec, signal: 2, password: password)
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

# ====================================================================== ANALYTICS
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
        .task {
            store.reload()
            if store.files.isEmpty { store.forceSeed() }
        }
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

# ====================================================================== GENERATOR
SKIP_DIRS = {".git", "_ios26_backup", "DerivedData", "build", ".build", "Pods"}

def _skip(p: Path) -> bool:
    return any(part in SKIP_DIRS or part.endswith(".xcodeproj") or part.endswith(".xcworkspace") for part in p.parts)

def find_target_dir(repo: Path) -> Path:
    for cand in ("Preferences", "Settings-iOS", "Settings"):
        p = repo / cand
        if p.is_dir() and any(p.rglob("*App.swift")):
            return p
    for app_file in repo.rglob("*App.swift"):
        if not _skip(app_file):
            return app_file.parent
    return repo / "Preferences"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".")
    ap.add_argument("--target", default=None)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    repo = Path(a.repo).resolve()
    target = Path(a.target).resolve() if a.target else find_target_dir(repo)
    backup = repo / "_ios26_backup"
    print(f"repo   : {repo}\ntarget : {target}\nfiles  : {len(FILES)}\nmode   : {'DRY RUN' if a.dry_run else 'write'}\n")

    dests = {(target / rel).resolve() for rel in FILES}
    names = {Path(rel).name for rel in FILES}
    print("Moving clashing files (same basename elsewhere) to backup:")
    for f in list(repo.rglob("*.swift")):
        if _skip(f) or f.resolve() in dests or f.name not in names:
            continue
        dest = backup / f.relative_to(repo)
        print(f"  -> {f.relative_to(repo)}")
        if not a.dry_run:
            dest.parent.mkdir(parents=True, exist_ok=True)
            if dest.exists(): dest.unlink()
            shutil.move(str(f), str(dest))

    print("\nWriting files:")
    for rel, content in FILES.items():
        dest = target / rel
        print(f"  + {dest.relative_to(repo)}")
        if not a.dry_run:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(content, encoding="utf-8")
    print("\nDone (part 2).")

if __name__ == "__main__":
    main()
