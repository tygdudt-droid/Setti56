import SwiftUI
import PhotosUI

/// Settings > [Apple Account]
///
/// Every push in here goes through `RouteLink` (String routes) so the iPad
/// detail stack can track and reset them when the sidebar selection changes.
struct AppleAccountView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(PrimarySettingsListModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var confirmSignOut = false
    @State private var showKeepData = false
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        if let account = store.account {
            CustomList(title: "Apple Account", topPadding: true) {
                Section {
                    VStack(spacing: 0) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            AvatarView(account: account, size: 96)
                        }
                        .buttonStyle(.plain)
                        Text(account.fullName)
                            .font(.system(size: 34, weight: .bold))
                            .padding(.top, 12)
                        Text(account.email)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 18)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    row("Personal Information", .tile("person.text.rectangle.fill", "8E8E93"))
                    row("Sign-In & Security", .tile("lock.shield.fill", "8E8E93"))
                    row("Payment & Shipping", .tile("creditcard.fill", "8E8E93"))
                    row("Subscriptions", .tile("arrow.triangle.2.circlepath.circle.fill", "8E8E93"))
                }

                Section {
                    row("iCloud", .uti("com.apple.application-icon.icloud"), value: "5 GB")
                    row("Family", .tile("person.2.fill", "2C7BE5"), value: "Set Up")
                    row("Find My", .app("com.apple.findmy", "location.fill", "34C759"))
                    row("Media & Purchases", .app("com.apple.AppStore", "square.stack.3d.up.fill", "1E90FF"))
                    row("Sign in with Apple", .tile("apple.logo", "000000"))
                }

                // Devices: no header in iOS 26, device renders instead of glyphs.
                Section {
                    let thisName = MockDevice.current.deviceName
                    let thisSubtitle = "This \(identity.modelName ?? MockDevice.current.modelName)"
                    RouteLink("AppleAccount/Device/this") {
                        DeviceDetailView(name: thisName, subtitle: thisSubtitle)
                    } label: {
                        deviceLabel(kind: MockDevice.current.isPad ? .iPad : .iPhone, name: thisName, subtitle: thisSubtitle)
                    }
                    ForEach(account.devices) { d in
                        let subtitle = d.model.isEmpty ? d.kind.rawValue : d.model
                        RouteLink("AppleAccount/Device/\(d.name)") {
                            DeviceDetailView(name: d.name, subtitle: subtitle)
                        } label: {
                            deviceLabel(kind: d.kind, name: d.name, subtitle: subtitle)
                        }
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) { confirmSignOut = true }
                        .frame(maxWidth: .infinity)
                }
            }
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
            .sheet(isPresented: $showKeepData) {
                KeepDataSheet { signOut() }
            }
        } else {
            ContentUnavailableView("Not Signed In", systemImage: "person.crop.circle.badge.xmark")
        }
    }

    private func signOut() {
        store.account = nil
        if UIDevice.iPhone || model.isCompact {
            dismiss()
        } else {
            // The detail column is driven by the sidebar selection on iPad.
            model.selection = model.mainSettings.first
        }
    }

    private func deviceLabel(kind: MockLinkedDevice.Kind, name: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Group {
                switch kind {
                case .iPad: DeviceImageView(isPad: true, scale: 0.6)
                case .iPhone: DeviceImageView(isPad: false, scale: 0.6)
                default: Image(systemName: kind.symbol).font(.title2)
                }
            }
            .frame(width: 34, height: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    /// Icon source for an Apple Account row.
    enum RowIcon {
        case tile(String, String)              // glyph + tint hex
        case app(String, String, String)       // bundle ID, fallback glyph, tint
        case uti(String)                       // Settings graphic / application icon UTI
    }

    private func row(_ title: String, _ icon: RowIcon, value: String? = nil) -> some View {
        RouteLink("AppleAccount/\(title)") {
            ContentUnavailableView(title, systemImage: "person.crop.circle")
        } label: {
            HStack(spacing: 12) {
                switch icon {
                case .tile(let symbol, let tint):
                    StorageIconView(icon: .app(bundleID: nil, symbol: symbol, tint: tint))
                case .app(let bundle, let symbol, let tint):
                    StorageIconView(icon: .app(bundleID: bundle, symbol: symbol, tint: tint))
                case .uti(let uti):
                    IconView(uti)
                }
                Text(title)
                Spacer()
                if let value { Text(value).foregroundStyle(.secondary) }
            }
        }
    }
}

/// Destination for the iCloud row in the main list.
struct ICloudDestinationView: View {
    @Environment(SettingsStore.self) private var store

    var body: some View {
        if store.account != nil {
            AppleAccountView()
        } else {
            ContentUnavailableView("Not Signed In", systemImage: "person.crop.circle.badge.xmark")
        }
    }
}

/// Settings > Apple Account > Devices > [Device] — matches iOS "Device Info".
struct DeviceDetailView: View {
    let name: String
    let subtitle: String
    private let device = MockDevice.current
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        // topPadding false pulls the header up under the bar like iOS.
        CustomList(title: "Device Info", topPadding: false) {
            Section {
                VStack(spacing: 5) {
                    DeviceImageView(isPad: device.isPad)
                        .padding(.bottom, 12)
                    Text(name)
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                RouteLink("DeviceInfo/FindMy") {
                    ContentUnavailableView("Find My", systemImage: "location.fill")
                } label: {
                    LabeledContent {
                        Text("On").foregroundStyle(.secondary)
                    } label: {
                        HStack(spacing: 12) {
                            // Real Find My app icon on device.
                            StorageIconView(icon: .app(bundleID: "com.apple.findmy", symbol: "location.fill", tint: "34C759"))
                            Text("Find My \(device.deviceTypeName)")
                        }
                    }
                }
                RouteLink("DeviceInfo/iCloudBackup") {
                    ContentUnavailableView("iCloud Backup", systemImage: "arrow.clockwise.icloud")
                } label: {
                    LabeledContent {
                        Text("On").foregroundStyle(.secondary)
                    } label: {
                        HStack(spacing: 12) {
                            StorageIconView(icon: .app(bundleID: nil, symbol: "arrow.clockwise", tint: "2AA9F0"))
                            Text("iCloud Backup")
                        }
                    }
                }
                RouteLink("DeviceInfo/AppleCare") {
                    ContentUnavailableView("AppleCare & Warranty", systemImage: "apple.logo")
                } label: {
                    HStack(spacing: 12) {
                        // White tile, red Apple logo — like iOS 26.
                        ZStack {
                            RoundedRectangle(cornerRadius: 6.5, style: .continuous).fill(Color.white)
                            Image(systemName: "apple.logo")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(red: 0.93, green: 0.20, blue: 0.20))
                        }
                        .frame(width: 29, height: 29)
                        Text("AppleCare & Warranty")
                    }
                }
            } footer: {
                Text("Last iCloud backup: July 12, 2025 at 18:13")
            }

            Section {
                LabeledContent("Model", value: identity.modelName ?? device.modelName)
                LabeledContent("Version", value: "\(device.systemName) \(identity.osVersion ?? device.systemVersion)")
                LabeledContent("Serial Number", value: identity.serialNumber)
                    .textSelection(.enabled)
            } header: {
                Text("Device Info").textCase(nil)
            } footer: {
                Text("This device is trusted and can receive Apple Account verification codes.")
            }
        }
    }

}

/// Small device rendering (frame + wallpaper) like the one iOS shows at the
/// top of Device Info: about 50×67pt for iPad, 34×68pt for iPhone.
struct DeviceImageView: View {
    var isPad: Bool
    var scale: CGFloat = 1

    var body: some View {
        let width: CGFloat = (isPad ? 50 : 34) * scale
        let height: CGFloat = (isPad ? 67 : 68) * scale
        let outerRadius: CGFloat = (isPad ? 6 : 8) * scale
        ZStack {
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .fill(Color(.systemGray4))
            RoundedRectangle(cornerRadius: outerRadius - 2.5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.20, blue: 0.55),
                            Color(red: 0.12, green: 0.55, blue: 0.85),
                            Color(red: 0.55, green: 0.85, blue: 0.95),
                            Color(red: 0.90, green: 0.96, blue: 1.00)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .padding(3 * scale)
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
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

#Preview {
    NavigationStack {
        AppleAccountView()
    }
    .environment(SettingsStore.shared)
    .environment(PrimarySettingsListModel())
}
