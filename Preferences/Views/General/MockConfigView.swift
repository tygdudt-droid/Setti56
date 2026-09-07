import SwiftUI
import PhotosUI

/// Hidden panel — open by long-pressing the "Contacts Only" row in
/// Settings > General > AirDrop (or "Serial Number" in About).
/// Lets you edit the mock device identity, Apple Account, and Wi-Fi networks.
struct MockConfigView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("DeviceName") private var deviceName = UIDevice.current.name

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
                } header: { Text("Devices").textCase(nil) } footer: { Text("Shown in Apple Account → Devices.") }
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
            } header: { Text("Wi-Fi Networks").textCase(nil) } footer: { Text("Swipe to delete. Tap a network to edit its name, password, security and state.") }

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
                store.storage = MockStorageSettings()
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
                SecureField("Password", text: $net.password)
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

#Preview {
    NavigationStack {
        MockConfigView()
    }
    .environment(SettingsStore.shared)
}

/// Hidden panel dedicated to Settings > General > [Device] Storage.
/// Long-press the first AirDrop option ("Receiving Off") to open it.
///
/// iOS does not let a sandboxed app enumerate third-party apps, so games and
/// other App Store apps are added here by name: the real icon, name and
/// download size come straight from the App Store.
struct StorageConfigView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var appsStore = StorageAppsStore.shared
    @State private var query = ""
    @State private var results: [AppStoreResult] = []
    @State private var searching = false
    @State private var addingBundleID: String?
    @State private var confirmClear = false

    private var detected: [InstalledApp] { InstalledAppsReader.visibleApps ?? [] }

    var body: some View {
        @Bindable var store = store
        List {
            // MARK: Add apps
            Section {
                HStack {
                    TextField("Search the App Store", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { Task { await runSearch() } }
                    if searching {
                        ProgressView()
                    } else {
                        Button("Search") { Task { await runSearch() } }
                            .buttonStyle(.borderless)
                            .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                ForEach(results) { result in
                    Button { Task { await add(result) } } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: result.artworkURL) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                                    .fill(Color(.systemGray4))
                            }
                            .frame(width: 34, height: 34)
                            .clipShape(RoundedRectangle(cornerRadius: 7.5, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.name).foregroundStyle(.primary)
                                Text(result.bundleID).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            if addingBundleID == result.bundleID {
                                ProgressView()
                            } else if appsStore.customApps.contains(where: { $0.bundleID == result.bundleID }) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            } else {
                                Image(systemName: "plus.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                }
            } header: {
                Text("Add Apps").textCase(nil)
            } footer: {
                Text("Search by name and tap an app to add it with its real icon. Needs an internet connection the first time; the icon is then kept on device.")
            }

            // MARK: Added apps
            if !appsStore.customApps.isEmpty {
                Section {
                    ForEach(appsStore.customApps) { app in
                        HStack(spacing: 12) {
                            addedIcon(app)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                Text(app.bundleID).font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            TextField("0", value: gigabytes(app), format: .number.precision(.fractionLength(0...2)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 70)
                            Text("GB").foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { appsStore.remove(appsStore.customApps[index].bundleID) }
                    }
                } header: {
                    Text("Added Apps").textCase(nil)
                } footer: {
                    Text("Swipe to remove. Edit the number to change the size shown in Storage.")
                }
            }

            // MARK: Detected apps
            Section {
                Toggle("Use Detected Apps", isOn: $store.useRealApps)
                if store.useRealApps {
                    ForEach(detected) { app in
                        Toggle(isOn: hiddenBinding(app.bundleID)) {
                            HStack(spacing: 12) {
                                StorageIconView(icon: .app(bundleID: app.bundleID, symbol: "app.fill", tint: "8E8E93"))
                                Text(app.name)
                            }
                        }
                    }
                }
            } header: {
                Text("Detected Apps").textCase(nil)
            } footer: {
                Text("\(InstalledAppsReader.diagnostic) Turn a row off to keep it out of the Storage list.")
            }

            // MARK: Storage numbers
            Section {
                numberField("Total capacity (GB)", value: $store.storage.totalGB)
                numberField("Photos (GB)", value: $store.storage.photosGB)
                numberField("iPadOS (GB)", value: $store.storage.osGB)
                numberField("System Data (GB)", value: $store.storage.systemDataGB)
            } header: {
                Text("Storage Usage").textCase(nil)
            } footer: {
                Text("Applications is the sum of the app list. Used = Applications + Photos + iPadOS + System Data; the remainder is shown as free space.")
            }

            Section {
                Toggle("Show Recommendations", isOn: $store.storage.showRecommendations)
                Toggle("Review Your Photos & Videos", isOn: $store.storage.reviewPhotosEnabled)
                numberField("Photos & Videos savings (GB)", value: $store.storage.reviewPhotosSaveGB)
                Toggle("“Recently Deleted” Album", isOn: $store.storage.recentlyDeletedEnabled)
                numberField("Recently Deleted savings (MB)", value: $store.storage.recentlyDeletedSaveMB)
            } header: {
                Text("Storage Recommendations").textCase(nil)
            } footer: {
                Text("Shown at the top of General → iPad Storage. Tapping Empty on the device turns the Recently Deleted card off; turn it back on here.")
            }

            Section {
                Button("Remove All Added Apps", role: .destructive) { confirmClear = true }
            }
        }
        .navigationTitle("Storage Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }.fontWeight(.semibold)
            }
        }
        .confirmationDialog("Remove all added apps?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Remove All", role: .destructive) { appsStore.removeAll() }
        }
    }

    // MARK: Pieces

    @ViewBuilder
    private func addedIcon(_ app: CustomStorageApp) -> some View {
        if let image = appsStore.icon(for: app.bundleID) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 29, height: 29)
                .clipShape(RoundedRectangle(cornerRadius: 6.5, style: .continuous))
        } else {
            StorageIconView(icon: .app(bundleID: app.bundleID, symbol: "app.fill", tint: "8E8E93"))
        }
    }

    private func numberField(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent(title) {
            TextField("0", value: value, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
        }
    }

    private func gigabytes(_ app: CustomStorageApp) -> Binding<Double> {
        Binding(
            get: { Double(app.bytes) / 1_000_000_000 },
            set: { appsStore.setBytes(Int64($0 * 1_000_000_000), for: app.bundleID) }
        )
    }

    private func hiddenBinding(_ bundleID: String) -> Binding<Bool> {
        Binding(
            get: { !appsStore.hiddenBundleIDs.contains(bundleID) },
            set: { appsStore.setHidden(!$0, for: bundleID) }
        )
    }

    private func runSearch() async {
        searching = true
        results = await AppStoreLookup.search(query)
        searching = false
    }

    private func add(_ result: AppStoreResult) async {
        addingBundleID = result.bundleID
        let data = await AppStoreLookup.iconData(from: result.artworkURL)
        appsStore.add(result, iconData: data)
        addingBundleID = nil
    }
}
