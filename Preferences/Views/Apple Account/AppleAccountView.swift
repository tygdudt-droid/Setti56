import SwiftUI
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
