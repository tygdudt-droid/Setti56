//
//  DeviceStorageView.swift
//  Preferences
//
//  Settings > General > [Device] Storage
//

import SwiftUI

/// One row of the per-app storage list.
struct StorageAppEntry: Identifiable {
    let app: MockApp
    let gb: Double
    var id: String { app.bundleID }
}

/// Mock recreation of the iOS 26 Storage pane: usage bar, per-app sizes,
/// Hidden Apps, and system rows.
struct DeviceStorageView: View {
    @Environment(SettingsStore.self) private var store

    private let totalGB: Double = 256
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var deviceName: String { isPad ? "iPad" : "iPhone" }
    private var osName: String { isPad ? "iPadOS" : "iOS" }

    // Mock category footprint (GB)
    private let applicationsGB: Double = 96.40
    private let photosGB: Double = 89.05
    private let osGB: Double = 20.67
    private let systemGB: Double = 8.00
    private var usedGB: Double { applicationsGB + photosGB + osGB + systemGB }

    /// Deterministic per-app sizes so the list is stable across launches.
    private var appSizes: [StorageAppEntry] {
        var rng = SeededGenerator(seed: 41)
        let apps = MockAppCatalog.all.filter { !store.hiddenAppBundleIDs.contains($0.bundleID) }
        var weights: [Double] = apps.map { _ in Double.random(in: 0.4...9.5, using: &rng) }
        let sum = weights.reduce(0, +)
        weights = weights.map { $0 / sum * applicationsGB }
        return zip(apps, weights).map(StorageAppEntry.init).sorted { $0.gb > $1.gb }
    }

    var body: some View {
        CustomList(title: "\(deviceName) Storage", topPadding: true) {
            // MARK: Usage header card
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(deviceName).font(.headline)
                        Spacer()
                        Text("\(String(format: "%.2f", usedGB)) GB of \(Int(totalGB)) GB used")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            bar(.red, fraction: applicationsGB / totalGB, width: geo.size.width)
                            bar(.orange, fraction: photosGB / totalGB, width: geo.size.width)
                            bar(.gray, fraction: osGB / totalGB, width: geo.size.width)
                            bar(.gray.opacity(0.5), fraction: systemGB / totalGB, width: geo.size.width)
                            bar(.clear, fraction: 1 - usedGB / totalGB, width: geo.size.width, isFree: true)
                        }
                    }
                    .frame(height: 18)
                    HStack(spacing: 14) {
                        legend(.red, "Applications")
                        legend(.orange, "Photos")
                        legend(.gray, "\(osName)")
                        legend(.gray.opacity(0.5), "System Data")
                    }
                    .font(.caption)
                }
                .padding(.vertical, 6)
            }

            // MARK: App usage list
            Section {
                ForEach(appSizes) { entry in
                    NavigationLink {
                        AppStorageDetailView(app: entry.app, sizeGB: entry.gb)
                    } label: {
                        HStack(spacing: 12) {
                            AppIconView(app: entry.app, side: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.app.name)
                                Text("Last used: Today")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(sizeLabel(entry.gb))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            } header: {
                HStack {
                    Text("Applications")
                    Spacer()
                    Text("Size")
                }
            }

            // MARK: Hidden Apps
            Section {
                NavigationLink {
                    HiddenAppsView()
                } label: {
                    Label("Hidden Apps", systemImage: "eye.slash")
                        .labelIconToTitleSpacing(12)
                }
            }

            // MARK: System rows
            Section {
                systemRow("\(osName)", osGB)
                systemRow("System Data", systemGB)
            }
        }
    }

    private func bar(_ color: Color, fraction: Double, width: CGFloat, isFree: Bool = false) -> some View {
        ZStack {
            if isFree {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(.secondary.opacity(0.4), lineWidth: 0.5)
            } else {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color)
            }
        }
        .frame(width: max(0, width * fraction))
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).foregroundStyle(.secondary)
        }
    }

    private func systemRow(_ title: String, _ gb: Double) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "gear")
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(.gray))
            Text(title)
            Spacer()
            Text(String(format: "%.2f GB", gb)).foregroundStyle(.secondary)
        }
    }

    private func sizeLabel(_ gb: Double) -> String {
        if gb >= 1 { return String(format: "%.2f GB", gb) }
        return String(format: "%.0f MB", gb * 1024)
    }
}

/// Mock per-app storage detail with offload/delete actions.
struct AppStorageDetailView: View {
    let app: MockApp
    let sizeGB: Double
    @State private var confirmDelete = false

    var body: some View {
        CustomList(title: app.name, topPadding: true) {
            Section {
                HStack(spacing: 14) {
                    AppIconView(app: app, side: 60)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name).font(.title3.weight(.semibold))
                        Text(String(format: "%.2f GB", sizeGB)).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                LabeledContent("App Size", value: String(format: "%.2f GB", sizeGB * 0.35))
                LabeledContent("Documents & Data", value: String(format: "%.2f GB", sizeGB * 0.65))
            }

            Section {
                Button("Offload App") {}
                Button("Delete App", role: .destructive) { confirmDelete = true }
            }
        }
        .confirmationDialog("Delete “\(app.name)”?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete App", role: .destructive) {}
        } message: {
            Text("Deleting this app will also delete its documents and data.")
        }
    }
}

#Preview {
    NavigationStack {
        DeviceStorageView()
    }
}
