#!/usr/bin/env python3
# generate_ios26_part2.py – run AFTER generate_ios26.py (and after the workflow post-fixes)
import os, re, glob, sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else '.')
P = os.path.join(ROOT, 'Preferences')
FILES = {}

# ------------------------------------------------------------------ components
FILES["Components/DetailMargins.swift"] = r'''import SwiftUI

/// iPadOS 26 style: detail content is centred with generous side margins.
struct DetailMarginsModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var width: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: { width = $0 })
            .contentMargins(.horizontal, margin, for: .scrollContent)
    }
    private var margin: CGFloat {
        guard sizeClass == .regular, width >= 520 else { return 0 }
        return max(20, (width - 680) / 2)
    }
}

/// Long-press (1.5 s) anywhere on the screen opens the hidden Device Config panel.
struct HiddenConfigTrigger: ViewModifier {
    @State private var show = false
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                show = true
            })
            .sheet(isPresented: $show) { NavigationStack { DeviceConfigView() } }
    }
}

extension View {
    func detailMargins() -> some View { modifier(DetailMarginsModifier()) }
    func hiddenConfigTrigger() -> some View { modifier(HiddenConfigTrigger()) }
}
'''

# ------------------------------------------------------------------ models
FILES["Models/DeviceConfig.swift"] = r'''import SwiftUI
import Observation

struct DeviceConfigData: Codable, Equatable {
    var deviceName = UIDevice.current.name
    var modelName = ""
    var modelNumber = ""
    var serialNumber = ""
    var osVersion = ""
    var coverage = "Coverage Expired"
    var capacityGB = 256.0
    var appsGB = 82.5
    var photosGB = 91.05
    var osGB = 20.67
    var systemGB = 7.22
    var songs = 0
    var videos = 357
    var photos = 2126
    var showPhotoRecommendation = false
    var wifiWeakSecurity = false
    var vpnConnected = false
    var devices: [String] = []
    var useSystemAuthForHiddenApps = false
}

@MainActor
@Observable
final class DeviceConfig {
    static let shared = DeviceConfig()
    var data: DeviceConfigData { didSet { save() } }

    private init() {
        data = UserDefaults.standard.data(forKey: "device.config")
            .flatMap { try? JSONDecoder().decode(DeviceConfigData.self, from: $0) } ?? DeviceConfigData()
    }
    private func save() { UserDefaults.standard.set(try? JSONEncoder().encode(data), forKey: "device.config") }
    func reset() { data = DeviceConfigData() }

    var effectiveModelName: String { data.modelName.isEmpty ? MockDevice.current.modelName : data.modelName }
    var effectiveModelNumber: String { data.modelNumber.isEmpty ? MockDeviceIdentity.stored.modelNumber : data.modelNumber }
    var effectiveSerial: String { data.serialNumber.isEmpty ? MockDeviceIdentity.stored.serialNumber : data.serialNumber }
    var effectiveOSVersion: String { data.osVersion.isEmpty ? MockDevice.current.systemVersion : data.osVersion }
    var usedGB: Double { data.appsGB + data.photosGB + data.osGB + data.systemGB }
    var availableGB: Double { max(0, data.capacityGB - usedGB) }
}

func fmtGB(_ v: Double) -> String {
    if v >= 1 {
        return v.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f GB", v) : String(format: "%.2f GB", v)
    }
    let mb = v * 1024
    if mb >= 1 { return String(format: "%.1f MB", mb) }
    return String(format: "%.0f KB", max(1, mb * 1024))
}
'''

# ------------------------------------------------------------------ hidden config panel
FILES["Views/Hidden/DeviceConfigView.swift"] = r'''import SwiftUI

struct DeviceConfigView: View {
    @State private var config = DeviceConfig.shared
    @State private var store = SettingsStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var signedIn = SettingsStore.shared.account != nil
    @State private var first = SettingsStore.shared.account?.firstName ?? "Apple"
    @State private var last = SettingsStore.shared.account?.lastName ?? "User"
    @State private var email = SettingsStore.shared.account?.email ?? "user@icloud.com"
    @State private var newDevice = ""

    private var accountKey: String { "\(signedIn)|\(first)|\(last)|\(email)" }

    var body: some View {
        @Bindable var config = config
        @Bindable var store = store
        List {
            Section("Device") {
                TextField("Name", text: $config.data.deviceName)
                TextField("Model Name (blank = automatic)", text: $config.data.modelName)
                TextField("Model Number", text: $config.data.modelNumber)
                TextField("Serial Number", text: $config.data.serialNumber)
                TextField("OS Version (blank = real)", text: $config.data.osVersion)
                Picker("Coverage", selection: $config.data.coverage) {
                    ForEach(["Coverage Expired", "Limited Warranty", "AppleCare+"], id: \.self) { Text($0) }
                }
            }
            Section("Storage") {
                Picker("Capacity", selection: $config.data.capacityGB) {
                    ForEach([64.0, 128.0, 256.0, 512.0, 1024.0], id: \.self) { Text("\(Int($0)) GB").tag($0) }
                }
                numberRow("Apps (GB)", $config.data.appsGB)
                numberRow("Photos (GB)", $config.data.photosGB)
                numberRow("System Data (GB)", $config.data.systemGB)
                LabeledContent("Available", value: fmtGB(config.availableGB))
                Toggle("Show “Review Your Photos & Videos”", isOn: $config.data.showPhotoRecommendation)
                Stepper("Photos: \(config.data.photos)", value: $config.data.photos, in: 0...100_000, step: 50)
                Stepper("Videos: \(config.data.videos)", value: $config.data.videos, in: 0...10_000, step: 5)
            }
            Section("Apple Account") {
                Toggle("Signed In", isOn: $signedIn)
                TextField("First Name", text: $first)
                TextField("Last Name", text: $last)
                TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
            }
            Section("Connected Devices") {
                ForEach(config.data.devices, id: \.self) { Text($0) }
                    .onDelete { config.data.devices.remove(atOffsets: $0) }
                HStack {
                    TextField("Add device (e.g. Chris’s MacBook Pro)", text: $newDevice)
                    Button("Add") {
                        guard !newDevice.isEmpty else { return }
                        config.data.devices.append(newDevice); newDevice = ""
                    }
                }
            }
            Section("Network") {
                Toggle("Wi-Fi On", isOn: $store.wifiEnabled)
                TextField("Connected network (blank = none)", text: connectedBinding)
                Menu("Pick a nearby network") {
                    ForEach(WiFiEngine.pool) { n in
                        Button(n.ssid) { store.connectedSSID = n.ssid; store.knownNetworkSSIDs.insert(n.ssid) }
                    }
                }
                Toggle("Show “Weak Security”", isOn: $config.data.wifiWeakSecurity)
                Toggle("VPN Connected", isOn: $config.data.vpnConnected)
            }
            Section("Hidden Apps") {
                Toggle("Require passcode", isOn: $store.requireAuthForHiddenApps)
                Toggle("Use Face ID instead of passcode", isOn: $config.data.useSystemAuthForHiddenApps)
                TextField("Passcode (6 digits)", text: $store.mockPasscode).keyboardType(.numberPad)
            }
            Section {
                Button("Reset to defaults", role: .destructive) {
                    config.reset(); store.account = nil; signedIn = false
                }
            }
        }
        .navigationTitle("Device Config")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { applyAccount(); dismiss() } } }
        .onChange(of: accountKey) { applyAccount() }
    }

    private var connectedBinding: Binding<String> {
        Binding(get: { store.connectedSSID ?? "" },
                set: { v in
                    store.connectedSSID = v.isEmpty ? nil : v
                    if !v.isEmpty { store.knownNetworkSSIDs.insert(v) }
                })
    }

    private func applyAccount() {
        if signedIn {
            var a = store.account ?? MockAppleAccount.from(email: email)
            a.firstName = first; a.lastName = last; a.email = email
            store.account = a
        } else {
            store.account = nil
        }
    }

    private func numberRow(_ title: String, _ value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: value, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 110)
        }
    }
}
'''

# ------------------------------------------------------------------ about
FILES["Views/General/AboutView.swift"] = r'''import SwiftUI

struct AboutView: View {
    @State private var config = DeviceConfig.shared
    @State private var showRegulatoryModel = false
    private let device = MockDevice.current
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        @Bindable var config = config
        List {
            Section {
                NavigationLink { DeviceNameView(name: $config.data.deviceName) } label: {
                    LabeledContent("Name", value: config.data.deviceName)
                }
                NavigationLink { IOSVersionView() } label: {
                    LabeledContent("\(device.systemName) Version", value: config.effectiveOSVersion)
                }
                LabeledContent("Model Name", value: config.effectiveModelName)
                LabeledContent("Model Number", value: showRegulatoryModel ? identity.regulatoryModel : config.effectiveModelNumber)
                    .contentShape(Rectangle())
                    .onTapGesture { showRegulatoryModel.toggle() }
                LabeledContent("Serial Number", value: config.effectiveSerial)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = config.effectiveSerial } }
            }
            Section {
                NavigationLink { CoverageView() } label: { Text(config.data.coverage) }
            }
            Section {
                LabeledContent("Songs", value: "\(config.data.songs)")
                LabeledContent("Videos", value: "\(config.data.videos)")
                LabeledContent("Photos", value: config.data.photos.formatted())
                LabeledContent("Applications", value: "\(MockAppCatalog.all.count + 28)")
                LabeledContent("Capacity", value: fmtGB(config.data.capacityGB))
                LabeledContent("Available", value: fmtGB(config.availableGB))
            }
            Section {
                LabeledContent("Wi-Fi Address", value: identity.wifiAddress)
                LabeledContent("Bluetooth", value: identity.bluetoothAddress)
                LabeledContent("Modem Firmware", value: identity.modemFirmware)
                LabeledContent("SEID", value: String(identity.seid.prefix(8)) + "…")
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.seid } }
                LabeledContent("EID", value: identity.eid)
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
            Section { NavigationLink("Certificate Trust Settings") { CertificateTrustView() } }
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
                    Text("\(d.systemName) \(DeviceConfig.shared.effectiveOSVersion)").font(.headline)
                    Text("Build \(d.buildNumber)").font(.footnote).foregroundStyle(.secondary)
                }
            } footer: {
                Text("\(d.systemName) 26 brings a beautiful new design with Liquid Glass, more expressive experiences across your apps, and intelligent features that make everyday tasks easier.")
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
                LabeledContent("Limited Warranty", value: DeviceConfig.shared.data.coverage == "Coverage Expired" ? "Expired" : "Active")
            } footer: {
                Text("Coverage information is provided by Apple based on the date of purchase.")
            }
            Section { Link("Learn About AppleCare+", destination: URL(string: "https://www.apple.com/support/products/")!) }
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
            Section { Toggle("Enable Full Trust for Root Certificates", isOn: $fullTrust) } footer: {
                Text("No certificates have been installed on this device.")
            }
        }
        .navigationTitle("Certificate Trust Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

# ------------------------------------------------------------------ storage
FILES["Views/General/DeviceStorageView.swift"] = r'''import SwiftUI

struct StorageApp: Identifiable {
    var id: String { name }
    let name: String
    let icon: String
    let tint: Color
    let gb: Double
    let lastUsed: String
}

struct StorageIcon: View {
    let icon: String
    let tint: Color
    var side: CGFloat = 40
    var body: some View {
        RoundedRectangle(cornerRadius: side * 0.2237, style: .continuous)
            .fill(LinearGradient(colors: [tint.opacity(0.85), tint], startPoint: .top, endPoint: .bottom))
            .frame(width: side, height: side)
            .overlay(Image(systemName: icon).font(.system(size: side * 0.46, weight: .medium)).foregroundStyle(.white))
    }
}

struct DeviceStorageView: View {
    @State private var config = DeviceConfig.shared
    @State private var query = ""
    @State private var sortBySize = true
    private let deviceType = MockDevice.current.deviceTypeName
    private let osName = MockDevice.current.isPad ? "iPadOS" : "iOS"

    private var apps: [StorageApp] {
        let weights: [Double] = [0.44, 0.24, 0.12, 0.07, 0.045, 0.03, 0.02, 0.012, 0.008, 0.005,
                                 0.003, 0.002, 0.0015, 0.001, 0.0008, 0.0006, 0.0004, 0.0003, 0.0002, 0.0001]
        let used = ["Today", "Today", "Yesterday", "Today", "3 days ago", "Last week", "Today", "2 weeks ago"]
        var list = [StorageApp(name: "Photos", icon: "photo.on.rectangle.angled", tint: .pink, gb: config.data.photosGB, lastUsed: "Yesterday")]
        for (i, app) in MockAppCatalog.all.enumerated() {
            let w = i < weights.count ? weights[i] : 0.0001
            list.append(StorageApp(name: app.name, icon: app.icon, tint: app.tint, gb: config.data.appsGB * w, lastUsed: used[i % used.count]))
        }
        let filtered = query.isEmpty ? list : list.filter { $0.name.localizedCaseInsensitiveContains(query) }
        return sortBySize ? filtered.sorted { $0.gb > $1.gb } : filtered.sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(deviceType).font(.headline)
                        Spacer()
                        Text("\(fmtGB(config.usedGB)) of \(fmtGB(config.data.capacityGB)) used").foregroundStyle(.secondary)
                    }
                    StorageBar(segments: [(config.data.appsGB, .red), (config.data.photosGB, .orange),
                                          (config.data.osGB, Color(.systemGray)), (config.data.systemGB, Color(.systemGray3))],
                               capacity: config.data.capacityGB, free: config.availableGB)
                    HStack(spacing: 14) {
                        legend("Applications", .red); legend("Photos", .orange)
                        legend(osName, Color(.systemGray)); legend("System Data", Color(.systemGray3))
                    }
                    .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section {
                if config.data.showPhotoRecommendation {
                    NavigationLink { ContentUnavailableView("Review Your Photos & Videos", systemImage: "photo.on.rectangle.angled") } label: {
                        recommendation(title: "Review Your Photos & Videos", trailing: nil,
                                       detail: "Save up to \(fmtGB(config.data.photosGB * 0.92)). See photos and videos taking up storage in the Photos app and consider deleting them.")
                    }
                }
                recommendation(title: "“Recently Deleted” Album", trailing: "Empty",
                               detail: "Save up to 75.7 MB. This will permanently delete all photos and videos kept in the “Recently Deleted” album.")
            } header: {
                HStack { Text("Recommendations"); Spacer(); Button("Show All") {}.font(.body).textCase(nil) }
            }

            Section {
                ForEach(apps) { app in
                    NavigationLink { StorageAppDetailView(app: app) } label: {
                        HStack(spacing: 12) {
                            StorageIcon(icon: app.icon, tint: app.tint)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                Text("Last used: \(app.lastUsed)").font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(fmtGB(app.gb)).foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Spacer()
                    Menu {
                        Button("Size") { sortBySize = true }
                        Button("Name") { sortBySize = false }
                    } label: {
                        Label(sortBySize ? "Size" : "Name", systemImage: "chevron.up.chevron.down")
                    }
                    .font(.body).textCase(nil)
                }
            }

            Section {
                NavigationLink { HiddenAppsScreen() } label: {
                    HStack(spacing: 12) {
                        StorageIcon(icon: "square.dashed", tint: Color(.systemGray4))
                        Text("Hidden Apps")
                    }
                }
            }

            Section {
                systemRow(osName, config.data.osGB)
                systemRow("System Data", config.data.systemGB)
            }
        }
        .navigationTitle("\(deviceType) Storage")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Applications")
    }

    private func legend(_ t: String, _ c: Color) -> some View {
        HStack(spacing: 4) { Circle().fill(c).frame(width: 8, height: 8); Text(t) }
    }

    private func recommendation(title: String, trailing: String?, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                StorageIcon(icon: "photo.on.rectangle.angled", tint: .pink)
                Text(title)
                Spacer()
                if let trailing { Button(trailing) {} }
            }
            Divider()
            Text(detail).font(.callout).foregroundStyle(.secondary).padding(.leading, 52)
        }
        .padding(.vertical, 4)
    }

    private func systemRow(_ title: String, _ gb: Double) -> some View {
        NavigationLink { ContentUnavailableView(title, systemImage: "gearshape") } label: {
            HStack(spacing: 12) {
                StorageIcon(icon: "gearshape.fill", tint: Color(.systemGray2))
                Text(title)
                Spacer()
                Text(fmtGB(gb)).foregroundStyle(.secondary)
            }
        }
    }
}

struct StorageBar: View {
    let segments: [(Double, Color)]
    let capacity: Double
    let free: Double
    var body: some View {
        GeometryReader { g in
            HStack(spacing: 2) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, s in
                    Rectangle().fill(s.1).frame(width: max(0, g.size.width * CGFloat(s.0 / capacity)))
                }
                ZStack {
                    Rectangle().fill(Color.primary.opacity(0.08))
                    Text(fmtGB(free)).font(.caption).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.6)
                }
            }
        }
        .frame(height: 22)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct StorageAppDetailView: View {
    let app: StorageApp
    @State private var confirmDelete = false
    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    StorageIcon(icon: app.icon, tint: app.tint, side: 60)
                    VStack(alignment: .leading) {
                        Text(app.name).font(.headline)
                        Text("Version 26.0").font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            Section {
                LabeledContent("App Size", value: fmtGB(app.gb * 0.35))
                LabeledContent("Documents & Data", value: fmtGB(app.gb * 0.65))
            }
            Section { Button("Offload App") {} } footer: {
                Text("This will free up storage used by the app, but keep its documents and data.")
            }
            Section { Button("Delete App", role: .destructive) { confirmDelete = true } } footer: {
                Text("This will delete the app and all related data from this \(MockDevice.current.deviceTypeName). This action can’t be undone.")
            }
        }
        .navigationTitle(app.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete “\(app.name)”?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete App", role: .destructive) {}
        }
    }
}
'''

# ------------------------------------------------------------------ hidden apps screen
FILES["Views/App Library/HiddenAppsScreen.swift"] = r'''import SwiftUI

/// Full-size Hidden Apps page (used from Apps and Storage). Passcode gate + staged de-blur reveal.
struct HiddenAppsScreen: View {
    @State private var store = SettingsStore.shared
    @State private var config = DeviceConfig.shared
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var unlocked = false
    @State private var showPasscode = false
    @State private var shake = 0

    private var hidden: [MockApp] { MockAppCatalog.all.filter { store.hiddenAppBundleIDs.contains($0.bundleID) } }
    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 20), count: sizeClass == .regular ? 6 : 4) }

    var body: some View {
        ScrollView {
            if hidden.isEmpty && unlocked {
                ContentUnavailableView {
                    Label("No Hidden Apps", systemImage: "eye.slash")
                } description: {
                    Text("Touch and hold an app in the App Library and choose Require Face ID to hide it.")
                }
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 28) {
                    ForEach(Array(hidden.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 8) {
                            AppIconView(app: app, side: 74)
                                .contextMenu {
                                    Button("Unhide", systemImage: "eye") {
                                        withAnimation(.spring()) { _ = store.hiddenAppBundleIDs.remove(app.bundleID) }
                                    }
                                }
                            Text(app.name).font(.footnote).lineLimit(1)
                        }
                        .blur(radius: unlocked ? 0 : 16)
                        .saturation(unlocked ? 1 : 0)
                        .scaleEffect(unlocked ? 1 : 0.85)
                        .opacity(unlocked ? 1 : 0.6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.72).delay(unlocked ? Double(i) * 0.05 : 0), value: unlocked)
                    }
                }
                .padding(24)
                .padding(.top, 40)
                .allowsHitTesting(unlocked)
            }
        }
        .overlay { if !unlocked { lockOverlay } }
        .modifier(ShakeEffect(shakes: shake))
        .navigationTitle("Hidden Apps")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                showPasscode = false
                if ok { reveal() } else { fail() }
            }
        }
        .onDisappear { unlocked = false }
    }

    private var lockOverlay: some View {
        VStack(spacing: 14) {
            Image(systemName: "eye.slash.fill").font(.system(size: 44)).foregroundStyle(.secondary)
            Text("Hidden Apps").font(.title2.bold())
            Text("Apps you have hidden are locked and don’t appear on the Home Screen, in search, or in notifications.")
                .multilineTextAlignment(.center).foregroundStyle(.secondary).frame(maxWidth: 380)
            Button("View Hidden Apps") { Task { await unlock() } }
                .glassProminentButton()
                .padding(.top, 6)
        }
        .padding(28)
        .glassCard(cornerRadius: 24)
        .padding()
    }

    private func unlock() async {
        guard store.requireAuthForHiddenApps else { reveal(); return }
        if config.data.useSystemAuthForHiddenApps, let ok = await HiddenAppsAuth.authenticate() {
            if ok { reveal() } else { fail() }
            return
        }
        showPasscode = true
    }

    private func reveal() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) { unlocked = true }
    }

    private func fail() {
        withAnimation(.default) { shake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
'''

# ------------------------------------------------------------------ apple account (devices from config)
FILES["Views/Apple Account/AppleAccountView.swift"] = r'''import SwiftUI
import PhotosUI

struct AppleAccountView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var config = DeviceConfig.shared
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
                                    .background(Capsule().fill(.thinMaterial)).offset(x: 4, y: 4)
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
                    deviceRow(config.data.deviceName, "This \(MockDevice.current.deviceTypeName)", MockDevice.current.isPad ? "ipad" : "iphone")
                    ForEach(config.data.devices, id: \.self) { d in deviceRow(d, kind(d), icon(d)) }
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
            } message: {
                Text("Signing out will remove iCloud data and turn off Find My for this device.")
            }
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

    private func deviceRow(_ name: String, _ subtitle: String, _ icon: String) -> some View {
        NavigationLink { ContentUnavailableView(name, systemImage: icon) } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.title2).frame(width: 34)
                VStack(alignment: .leading) {
                    Text(name)
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func icon(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("mac") { return "macbook" }
        if n.contains("ipad") { return "ipad" }
        if n.contains("watch") { return "applewatch" }
        if n.contains("tv") { return "appletv" }
        if n.contains("vision") { return "visionpro" }
        return "iphone"
    }
    private func kind(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("macbook") { return "MacBook Pro" }
        if n.contains("mac") { return "Mac" }
        if n.contains("ipad") { return "iPad" }
        if n.contains("watch") { return "Apple Watch" }
        if n.contains("tv") { return "Apple TV" }
        if n.contains("vision") { return "Apple Vision Pro" }
        return "iPhone"
    }
}
'''

# ------------------------------------------------------------------ wi-fi (iPadOS 26 layout)
FILES["Views/Radios/Network/NetworkRow.swift"] = r'''import SwiftUI

struct NetworkRow: View {
    enum State { case idle, connected, joining }
    let network: MockWiFiNetwork
    let state: State
    var subtitle: String? = nil
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
            VStack(alignment: .leading, spacing: 2) {
                Text(network.ssid)
                if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(.secondary) }
            }
            Spacer()
            HStack(spacing: 12) {
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

FILES["Views/Radios/Network/WiFiView.swift"] = r'''import SwiftUI

struct WiFiView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var engine = WiFiEngine()
    @State private var config = DeviceConfig.shared
    @State private var joining: MockWiFiNetwork?
    @AppStorage("wifi.askToJoin") private var askToJoin = "Notify"
    @AppStorage("wifi.autoHotspot") private var autoHotspot = "Automatic"

    private var connected: MockWiFiNetwork? {
        guard store.wifiEnabled, let ssid = store.connectedSSID, !ssid.isEmpty else { return nil }
        return WiFiEngine.network(for: ssid) ?? MockWiFiNetwork(ssid: ssid, security: .wpa2, signal: 3, isHotspot: false)
    }
    private var askFooter: String {
        switch askToJoin {
        case "Off": return "Known networks will be joined automatically. If no known networks are available, you will have to manually select a network."
        case "Ask": return "Known networks will be joined automatically. If no known networks are available, you will be asked before joining a new network."
        default: return "Known networks will be joined automatically. If no known networks are available, you will be notified of available networks."
        }
    }

    var body: some View {
        @Bindable var store = store
        List {
            Section {
                if sizeClass == .regular {
                    VStack(alignment: .leading, spacing: 10) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.blue).frame(width: 64, height: 64)
                            .overlay(Image(systemName: "wifi").font(.system(size: 32, weight: .semibold)).foregroundStyle(.white))
                        Text("Wi-Fi").font(.title2.bold()).padding(.top, 6)
                        Text("Connect to Wi-Fi, view available networks, and manage settings for joining networks and nearby hotspots. [Learn more...](https://support.apple.com/HT202639)")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                Toggle("Wi-Fi", isOn: $store.wifiEnabled)
                if let net = connected {
                    NetworkRow(network: net, state: .connected, subtitle: config.data.wifiWeakSecurity ? "Weak Security" : nil) {}
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
                    ForEach(engine.visible.filter { !store.knownNetworkSSIDs.contains($0.ssid) && $0.ssid != store.connectedSSID }) { n in
                        NetworkRow(network: n, state: .idle) { joining = n }
                    }
                    NavigationLink("Other...") { OtherNetworkView() }
                } header: {
                    HStack(spacing: 8) {
                        Text("Networks")
                        if engine.scanning { ProgressView().controlSize(.mini) }
                    }
                }
                Section {
                    NavigationLink { OptionPickerView(title: "Ask to Join Networks", options: ["Off", "Notify", "Ask"], selection: $askToJoin) } label: {
                        LabeledContent("Ask to Join Networks", value: askToJoin)
                    }
                } footer: { Text(askFooter) }
                Section {
                    NavigationLink { OptionPickerView(title: "Auto-Join Hotspot", options: ["Never", "Ask to Join", "Automatic"], selection: $autoHotspot) } label: {
                        LabeledContent("Auto-Join Hotspot", value: autoHotspot)
                    }
                } footer: {
                    Text("Allow this device to automatically discover nearby personal hotspots when no Wi-Fi network is available.")
                }
            }
        }
        .navigationTitle(sizeClass == .regular ? "" : "Wi-Fi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { if store.wifiEnabled { EditButton() } }
        .sheet(item: $joining) { JoinNetworkSheet(network: $0, engine: engine) }
        .task { engine.startScanning() }
        .onChange(of: store.wifiEnabled) { _, on in on ? engine.startScanning() : engine.stopScanning() }
        .onDisappear { engine.stopScanning() }
    }
}

struct OptionPickerView: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    var body: some View {
        List {
            ForEach(options, id: \.self) { o in
                HStack {
                    Text(o)
                    Spacer()
                    if o == selection { Image(systemName: "checkmark").foregroundStyle(.tint) }
                }
                .contentShape(Rectangle())
                .onTapGesture { selection = o }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
'''

FILES["Views/Radios/Network/NetworkDetailView.swift"] = r'''import SwiftUI

extension WiFiEngine { static let shared = WiFiEngine() }

struct NetworkDetailView: View {
    let network: MockWiFiNetwork
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var config = DeviceConfig.shared
    @State private var confirmForget = false

    private var key: String { network.ssid.replacingOccurrences(of: " ", with: "_") }
    private var isKnown: Bool { store.knownNetworkSSIDs.contains(network.ssid) || isConnected }
    private var isConnected: Bool { store.connectedSSID == network.ssid }
    private var ipHost: Int { 20 + network.ssid.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 200 }
    private var deviceType: String { MockDevice.current.deviceTypeName }

    var body: some View {
        List {
            if isConnected && config.data.wifiWeakSecurity {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weak Security").font(.headline)
                        Text("WPA/WPA2 (TKIP) is not considered secure.")
                        Text("If this is your Wi-Fi network, configure the router to use WPA2 (AES) or WPA3 security type.")
                    }
                    .padding(.vertical, 4)
                } footer: {
                    Link("Learn more about recommended settings for Wi-Fi...", destination: URL(string: "https://support.apple.com/HT202068")!).font(.body)
                }
            }
            if isKnown {
                Section { Button("Forget This Network") { confirmForget = true } }
            }
            Section {
                WiFiToggleRow(title: "Auto-Join", key: "wifi.\(key).autoJoin", def: true)
                if network.security.isSecured { LabeledContent("Password", value: "••••••••••••") }
            }
            Section {
                WiFiToggleRow(title: "Low Data Mode", key: "wifi.\(key).lowData", def: false)
            } footer: {
                Text("Low Data Mode helps reduce your \(deviceType) data usage over your cellular network or specific Wi-Fi networks you select. When Low Data Mode is turned on, automatic updates and background tasks, such as Photos syncing, are paused.")
            }
            Section {
                WiFiPickerRow(title: "Private Wi-Fi Address", key: "wifi.\(key).private", options: ["Off", "Fixed", "Rotating"], def: "Rotating")
                LabeledContent("Wi-Fi Address", value: MockDeviceIdentity.stored.wifiAddress)
            } footer: {
                Text("Wi-Fi networks and devices can track other nearby Wi-Fi devices by their Wi-Fi address, even on secure networks. A rotating private address reduces tracking by periodically changing this device’s Wi-Fi address on this network.")
            }
            Section {
                WiFiToggleRow(title: "Limit IP Address Tracking", key: "wifi.\(key).limitIP", def: true)
            } footer: {
                Text("Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari.")
            }
            if isConnected {
                Section("IPv4 Address") {
                    NavigationLink { ContentUnavailableView("Configure IPv4", systemImage: "network") } label: { LabeledContent("Configure IP", value: "Automatic") }
                    LabeledContent("IP Address", value: "192.168.100.\(ipHost)")
                    LabeledContent("Subnet Mask", value: "255.255.255.0")
                    LabeledContent("Router", value: "192.168.100.1")
                }
                Section("DNS") {
                    NavigationLink { ContentUnavailableView("Configure DNS", systemImage: "network") } label: { LabeledContent("Configure DNS", value: "Automatic") }
                }
                Section("HTTP Proxy") {
                    NavigationLink { ContentUnavailableView("Configure Proxy", systemImage: "network") } label: { LabeledContent("Configure Proxy", value: "Off") }
                }
            }
        }
        .navigationTitle(network.ssid)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Forget Wi-Fi Network “\(network.ssid)”?", isPresented: $confirmForget, titleVisibility: .visible) {
            Button("Forget", role: .destructive) { WiFiEngine.shared.forget(network.ssid); dismiss() }
        } message: {
            Text("Your \(deviceType) will no longer join this Wi-Fi network.")
        }
    }
}

struct WiFiToggleRow: View {
    let title: String; let key: String; let def: Bool
    @State private var value = false
    var body: some View {
        Toggle(title, isOn: $value)
            .onAppear { value = UserDefaults.standard.object(forKey: key) as? Bool ?? def }
            .onChange(of: value) { _, v in UserDefaults.standard.set(v, forKey: key) }
    }
}

struct WiFiPickerRow: View {
    let title: String; let key: String; let options: [String]; let def: String
    @State private var value = ""
    var body: some View {
        NavigationLink { OptionPickerView(title: title, options: options, selection: $value) } label: {
            LabeledContent(title, value: value)
        }
        .onAppear { if value.isEmpty { value = UserDefaults.standard.string(forKey: key) ?? def } }
        .onChange(of: value) { _, v in UserDefaults.standard.set(v, forKey: key) }
    }
}
'''

# ------------------------------------------------------------------ helpers
PART1 = ("SeededGenerator MockDevice MockDeviceIdentity SettingsStore MockAppleAccount WiFiModels MockAppCatalog "
         "BatteryDataProvider ScreenTimeProvider AnalyticsStore AnalyticsFileTemplates HiddenAppsAuth GlassCompat "
         "AppIconView MockAppIconView ShakeEffect MockPasscodeSheet AboutView AvatarView AppleAccountRow "
         "AppleAccountSignInSheet AppleAccountView WiFiView NetworkRow JoinNetworkSheet NetworkDetailView "
         "OtherNetworkView BatteryView BatteryHeaderCard BatteryLevelChart BatteryHealthView ScreenTimeView "
         "ScreenTimeWeekChart ScreenTimeActivityView ScreenTimeSubViews AnalyticsImprovementsView AnalyticsDataView "
         "AppLibraryView CategoryFolderTile FolderExpandedView HiddenFolderTile ShortcutIconHelper").split()
GENERATED = {n + '.swift' for n in PART1} | {os.path.basename(k) for k in FILES}


def read(p): return open(p, encoding='utf-8').read()
def write(p, s):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w', encoding='utf-8').write(s)
def swift_files():
    return [f for f in glob.glob(os.path.join(P, '**', '*.swift'), recursive=True) if 'Preview Content' not in f]
def originals():
    return [f for f in swift_files() if os.path.basename(f) not in GENERATED]
def struct_name(s):
    m = re.search(r'struct\s+(\w+)\s*:\s*View\b', s)
    return m.group(1) if m else None
def called_with_args(name):
    rx = re.compile(r'\b' + re.escape(name) + r'\s*\(\s*[^)\s]')
    return any(rx.search(read(f)) for f in swift_files())
def forward(path, target):
    s = read(path)
    n = struct_name(s)
    if not n or n == target:
        return None
    if called_with_args(n):
        print('  !! not forwarded (called with arguments):', os.path.relpath(path, ROOT), n)
        return None
    body = 'import SwiftUI\n\n// Forwarded to the iOS 26 implementation.\nstruct ' + n + ': View {\n    var body: some View { ' + target + '() }\n}\n'
    write(path, body)
    print('  -> ' + n + ' now shows ' + target + '  (' + os.path.relpath(path, ROOT) + ')')
    return n


def main():
    print('writing part-2 files:')
    for rel, content in FILES.items():
        write(os.path.join(P, rel), content)
        print('  +', rel)

    # 1) Analytics: original data view / improvements page -> new implementation
    print('analytics routing:')
    leaf = None
    for f in originals():
        if re.search(r'no\s*diagnostic\s*data|noDiagnosticData|no\s*analytics\s*data', read(f), re.I):
            leaf = forward(f, 'AnalyticsDataView'); break
    if leaf:
        for f in originals():
            s = read(f)
            if not re.search(r'\b' + leaf + r'\s*\(', s): continue
            if re.search(r'nalytic', struct_name(s) or ''):
                forward(f, 'AnalyticsImprovementsView')
            else:
                write(f, re.sub(r'\b' + leaf + r'\s*\(\s*\)', 'AnalyticsDataView()', s))
                print('  leaf reference replaced in', os.path.relpath(f, ROOT))
    for f in originals():
        s = read(f); n = struct_name(s) or ''
        if re.match(r'^Analytics\w*View$', n) and 'Toggle' in s:
            forward(f, 'AnalyticsImprovementsView')
    if not leaf:
        print('  !! original analytics data view not found')

    # 2) Storage screen
    print('storage routing:')
    hit = False
    for f in originals():
        b = os.path.basename(f)
        if re.search(r'Storage', b) and not re.search(r'cloud', b, re.I) and b.endswith('View.swift'):
            hit = forward(f, 'DeviceStorageView') is not None or hit
    if not hit: print('  !! no *Storage*View.swift found')

    # 3) Hidden apps screen
    print('hidden apps routing:')
    for f in originals():
        if os.path.basename(f) == 'HiddenAppsView.swift':
            forward(f, 'HiddenAppsScreen')

    # 4) App Library link in Home Screen settings
    print('app library link:')
    for f in originals():
        if re.search(r'HomeScreen', os.path.basename(f)):
            s = read(f)
            if 'AppLibraryView()' in s: continue
            new, n = re.subn(r'(\b(?:Custom)?List\b[^{\n]*\{)',
                             r'\1\n            Section { NavigationLink("App Library") { AppLibraryView() } }', s, count=1)
            if n:
                write(f, new); print('  + link added in', os.path.relpath(f, ROOT))

    # 5) Hidden config trigger: AirDrop screen (fallback: About)
    print('hidden config trigger:')
    placed = False
    for f in originals():
        if re.search(r'AirDrop', os.path.basename(f)):
            s = read(f)
            if '.navigationTitle(' in s and 'hiddenConfigTrigger' not in s:
                write(f, s.replace('.navigationTitle(', '.hiddenConfigTrigger().navigationTitle(', 1))
                print('  + long-press trigger in', os.path.relpath(f, ROOT)); placed = True; break
    if not placed:
        a = os.path.join(P, 'Views/General/AboutView.swift')
        write(a, read(a).replace('.navigationTitle("About")', '.hiddenConfigTrigger().navigationTitle("About")'))
        print('  !! AirDrop file not found - trigger placed on About (long-press)')

    # 6) iPad detail margins on every screen
    print('detail margins:')
    count = 0
    for f in swift_files():
        if os.path.basename(f) == 'DetailMargins.swift': continue
        s = read(f)
        if '.navigationTitle(' not in s or 'detailMargins()' in s: continue
        write(f, re.sub(r'(?<![\w.])\.navigationTitle\(', '.detailMargins().navigationTitle(', s)); count += 1
    print('  applied to', count, 'files')

    # 7) Root list Wi-Fi status
    print('wifi status text:')
    for f in originals():
        s = read(f)
        if '"Not Connected"' in s and ': View' in s:
            write(f, s.replace('"Not Connected"', '(SettingsStore.shared.connectedSSID ?? "Not Connected")'))
            print('  patched', os.path.relpath(f, ROOT))
    print('part 2 done')


if __name__ == '__main__':
    main()
