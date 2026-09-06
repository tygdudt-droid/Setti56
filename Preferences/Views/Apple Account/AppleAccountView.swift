import SwiftUI
import PhotosUI

struct AppleAccountView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var confirmSignOut = false
    @State private var showKeepData = false
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        if let account = store.account {
            CustomList(title: "Apple Account", topPadding: true) {
                Section {
                    VStack(spacing: 10) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            AvatarView(account: account, size: 110)
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
                    row("iCloud", "icloud.fill", .blue, value: "5 GB")
                    row("Family", "person.2.fill", .blue, value: "Set Up")
                    row("Find My", "location.fill", .green)
                    row("Media & Purchases", "square.stack.3d.up.fill", .blue)
                    row("Sign in with Apple", "apple.logo", .white, iconTint: .black)
                }

                Section(header: Text("Devices").textCase(nil)) {
                    NavigationLink {
                        DeviceDetailView(name: MockDevice.current.deviceName,
                                         subtitle: "This \(identity.modelName ?? MockDevice.current.modelName)")
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: MockDevice.current.isPad ? "ipad" : "iphone").font(.title2)
                            VStack(alignment: .leading) {
                                Text(MockDevice.current.deviceName)
                                Text("This \(identity.modelName ?? MockDevice.current.modelName)").font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                    ForEach(account.devices) { d in
                        NavigationLink {
                            DeviceDetailView(name: d.name, subtitle: d.model.isEmpty ? d.kind.rawValue : d.model)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: d.kind.symbol).font(.title2)
                                VStack(alignment: .leading) {
                                    Text(d.name)
                                    Text(d.model.isEmpty ? d.kind.rawValue : d.model).font(.footnote).foregroundStyle(.secondary)
                                }
                            }
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
            .sheet(isPresented: $showKeepData) { KeepDataSheet { store.account = nil; dismiss() } }
        } else {
            ContentUnavailableView("Not Signed In", systemImage: "person.crop.circle.badge.xmark")
        }
    }

    private func row(_ title: String, _ icon: String, _ color: Color, value: String? = nil, iconTint: Color = .white) -> some View {
        NavigationLink { ContentUnavailableView(title, systemImage: icon) } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(iconTint).frame(width: 29, height: 29)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
                Text(title)
                Spacer()
                if let value { Text(value).foregroundStyle(.secondary) }
            }
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
        CustomList(title: "Device Info", topPadding: true) {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: device.isPad ? "ipad.landscape" : "iphone.gen3")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.primary)
                    Text(name).font(.title3.weight(.semibold))
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section {
                NavigationLink { ContentUnavailableView("Find My", systemImage: "location.fill") } label: {
                    LabeledContent {
                        Text("On").foregroundStyle(.secondary)
                    } label: {
                        iconRow("Find My \(device.deviceTypeName)", "location.fill", .green)
                    }
                }
                NavigationLink { ContentUnavailableView("iCloud Backup", systemImage: "arrow.clockwise.icloud") } label: {
                    LabeledContent {
                        Text("On").foregroundStyle(.secondary)
                    } label: {
                        iconRow("iCloud Backup", "arrow.triangle.2.circlepath", .teal)
                    }
                }
                NavigationLink { ContentUnavailableView("AppleCare & Warranty", systemImage: "apple.logo") } label: {
                    iconRowLink("AppleCare & Warranty", "apple.logo", .white, tint: .black)
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

    private func iconRow(_ title: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.white).frame(width: 29, height: 29)
                .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
            Text(title)
        }
    }

    private func iconRowLink(_ title: String, _ icon: String, _ color: Color, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(tint).frame(width: 29, height: 29)
                .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
            Text(title)
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

#Preview {
    NavigationStack {
        AppleAccountView()
    }
    .environment(SettingsStore.shared)
}
