//
//  DeviceStorageView.swift
//  Preferences
//
//  Settings > General > [Device] Storage
//

import SwiftUI

// MARK: - Mock data

/// Editable numbers for the Storage pane (Mock Configuration → Storage).
struct MockStorageSettings: Codable, Equatable {
    var totalGB: Double = 256
    var photosGB: Double = 91.05          // "Photos" category = Photos app row
    var osGB: Double = 20.67
    var systemDataGB: Double = 7.22
    var showRecommendations = true
    var reviewPhotosEnabled = true
    var reviewPhotosSaveGB: Double = 83.63
    var recentlyDeletedEnabled = true
    var recentlyDeletedSaveMB: Double = 75.7

    init() {}

    private enum CodingKeys: String, CodingKey {
        case totalGB, photosGB, osGB, systemDataGB, showRecommendations
        case reviewPhotosEnabled, reviewPhotosSaveGB, recentlyDeletedEnabled, recentlyDeletedSaveMB
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalGB = try c.decodeIfPresent(Double.self, forKey: .totalGB) ?? 256
        photosGB = try c.decodeIfPresent(Double.self, forKey: .photosGB) ?? 91.05
        osGB = try c.decodeIfPresent(Double.self, forKey: .osGB) ?? 20.67
        systemDataGB = try c.decodeIfPresent(Double.self, forKey: .systemDataGB) ?? 7.22
        showRecommendations = try c.decodeIfPresent(Bool.self, forKey: .showRecommendations) ?? true
        reviewPhotosEnabled = try c.decodeIfPresent(Bool.self, forKey: .reviewPhotosEnabled) ?? true
        reviewPhotosSaveGB = try c.decodeIfPresent(Double.self, forKey: .reviewPhotosSaveGB) ?? 83.63
        recentlyDeletedEnabled = try c.decodeIfPresent(Bool.self, forKey: .recentlyDeletedEnabled) ?? true
        recentlyDeletedSaveMB = try c.decodeIfPresent(Double.self, forKey: .recentlyDeletedSaveMB) ?? 75.7
    }
}

/// How a storage row draws its icon.
enum StorageIcon {
    /// Real app icon when the bundle is installed, otherwise a tinted glyph.
    case app(bundleID: String?, symbol: String, tint: String)
    /// Two (side by side) or four (2×2) tiny glyph tiles — grouped developers.
    case multi([(symbol: String, tint: String)])
    /// Artwork downloaded for an app added by hand.
    case custom(UIImage)
}

/// One row of the storage list.
struct StorageEntry: Identifiable {
    let id: String
    let name: String
    let icon: StorageIcon
    var bytes: Int64
    var lastUsed: String? = nil
    var offloaded = false
    /// The two lines under the app name in the detail pane: `1.0.57`, then
    /// the seller, `Activision Publishing, Inc.`
    var version: String? = nil
    var publisher: String? = nil
    /// App Size; the rest of `bytes` is Documents & Data. `nil` falls back to
    /// a typical split.
    var appBytes: Int64? = nil

    /// Last-used rank for sorting (Today first, never-used last).
    var lastUsedRank: Int {
        switch lastUsed {
        case "Today": return 0
        case "Yesterday": return 1
        case .some: return 2
        case .none: return 3
        }
    }
}

enum StorageSort: CaseIterable {
    case size, name, lastUsed

    var title: String {
        switch self {
        case .size: return "Size"
        case .name: return "Name"
        case .lastUsed: return "Last Used"
        }
    }
}

/// Fixed catalog mirroring a real iPad. Sizes are 1000-based like iOS.
enum MockStorageCatalog {
    static func gb(_ v: Double) -> Int64 { Int64(v * 1_000_000_000) }
    static func mb(_ v: Double) -> Int64 { Int64(v * 1_000_000) }
    static func kb(_ v: Double) -> Int64 { Int64(v * 1_000) }

    static let photosID = "com.apple.mobileslideshow"

    /// Everything except the Photos row (its size comes from `MockStorageSettings.photosGB`).
    /// Only pass a bundle ID for apps that are really installed: the private
    /// icon lookup returns a blank template (not nil) for unknown bundles.
    static var apps: [StorageEntry] { [
        StorageEntry(id: "telegram", name: "Telegram", icon: .app(bundleID: "ph.telegra.Telegraph", symbol: "paperplane.fill", tint: "2AABEE"), bytes: gb(40.24), lastUsed: "Today", version: "12.1.1", publisher: "Telegram FZ-LLC"),
        StorageEntry(id: "cod", name: "Call of Duty", icon: .app(bundleID: "com.activision.callofduty.shooter", symbol: "scope", tint: "1C1C1E"), bytes: gb(30.58), lastUsed: "Today", version: AppRelease.stored.version, publisher: "Activision Publishing, Inc.", appBytes: gb(3.04)),
        StorageEntry(id: "inshot", name: "InShot", icon: .app(bundleID: nil, symbol: "camera.fill", tint: "FF2D55"), bytes: gb(10.76), lastUsed: "Today"),
        StorageEntry(id: "spotify", name: "Spotify", icon: .app(bundleID: nil, symbol: "music.note", tint: "1DB954"), bytes: gb(4.62), lastUsed: "Today"),
        StorageEntry(id: "instagram", name: "Instagram", icon: .app(bundleID: "com.burbn.instagram", symbol: "camera.circle.fill", tint: "E1306C"), bytes: gb(2.41), lastUsed: "Today"),
        StorageEntry(id: "whatsapp", name: "WhatsApp", icon: .app(bundleID: "net.whatsapp.WhatsApp", symbol: "phone.fill", tint: "25D366"), bytes: gb(1.87), lastUsed: "Today"),
        StorageEntry(id: "netflix", name: "Netflix", icon: .app(bundleID: nil, symbol: "play.rectangle.fill", tint: "E50914"), bytes: gb(1.31), lastUsed: "Yesterday"),
        StorageEntry(id: "youtube", name: "YouTube", icon: .app(bundleID: nil, symbol: "play.fill", tint: "FF0000"), bytes: gb(1.26), lastUsed: "Today"),
        StorageEntry(id: "sniper", name: "Sniper 3D", icon: .app(bundleID: nil, symbol: "scope", tint: "3A3A3C"), bytes: gb(1.13)),
        StorageEntry(id: "chrome", name: "Chrome", icon: .app(bundleID: nil, symbol: "globe", tint: "4285F4"), bytes: gb(1.02), lastUsed: "Yesterday"),
        StorageEntry(id: "magictiles", name: "Magic Tiles 3", icon: .app(bundleID: nil, symbol: "pianokeys", tint: "AF52DE"), bytes: mb(792.8)),
        StorageEntry(id: "files", name: "Files", icon: .app(bundleID: "com.apple.DocumentsApp", symbol: "folder.fill", tint: "007AFF"), bytes: mb(120.5), lastUsed: "Today"),
        StorageEntry(id: "facetime", name: "FaceTime", icon: .app(bundleID: "com.apple.facetime", symbol: "video.fill", tint: "34C759"), bytes: mb(14.1)),
        StorageEntry(id: "magnifier", name: "Magnifier", icon: .app(bundleID: "com.apple.Magnifier", symbol: "plus.magnifyingglass", tint: "1C1C1E"), bytes: mb(2)),
        StorageEntry(id: "rtsce", name: "RTS:CE", icon: .app(bundleID: nil, symbol: "gamecontroller.fill", tint: "FF6B00"), bytes: mb(1.9), offloaded: true),
        StorageEntry(id: "evony", name: "Evony", icon: .app(bundleID: nil, symbol: "shield.lefthalf.filled", tint: "C0392B"), bytes: mb(1.6), offloaded: true),
        StorageEntry(id: "namasho", name: "نماشو", icon: .app(bundleID: nil, symbol: "play.fill", tint: "8E24AA"), bytes: kb(201)),
        StorageEntry(id: "visionsetup", name: "Apple Vision Pro Setup", icon: .app(bundleID: nil, symbol: "visionpro", tint: "8E8E93"), bytes: kb(78)),
        StorageEntry(id: "onmyipad", name: "On My iPad", icon: .app(bundleID: nil, symbol: "ipad", tint: "8E8E93"), bytes: kb(45)),
        StorageEntry(id: "bale", name: "Bale", icon: .app(bundleID: nil, symbol: "checkmark.shield.fill", tint: "1E88E5"), bytes: kb(45)),
        StorageEntry(id: "eitaa", name: "Eitaa", icon: .app(bundleID: nil, symbol: "bubble.left.fill", tint: "F4511E"), bytes: kb(45)),
        StorageEntry(id: "soroush", name: "سروش پلاس", icon: .app(bundleID: nil, symbol: "message.fill", tint: "1565C0"), bytes: kb(41)),
        StorageEntry(id: "bam", name: "بام", icon: .app(bundleID: nil, symbol: "b.square.fill", tint: "FB8C00"), bytes: kb(33)),
        StorageEntry(id: "metagroup", name: "Instagram, Inc. and WhatsApp Inc.",
                     icon: .multi([("camera.circle.fill", "E1306C"), ("phone.fill", "25D366")]), bytes: kb(33)),
        StorageEntry(id: "cluster", name: "",
                     icon: .multi([("camera.circle.fill", "E1306C"), ("gearshape.fill", "8E8E93"), ("phone.fill", "25D366"), ("photo.fill", "FF9500")]), bytes: kb(20))
    ] }

    static func photosRow(gb value: Double) -> StorageEntry {
        StorageEntry(id: photosID, name: "Photos",
                     icon: .app(bundleID: photosID, symbol: "photo.on.rectangle.angled", tint: "FFFFFF"),
                     bytes: gb(value), lastUsed: "Yesterday")
    }

    /// "91.05 GB", "792.8 MB", "201 KB" — same rules as iOS.
    static func format(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

// MARK: - Views

/// Mock recreation of the iPadOS/iOS 26 Storage pane: usage bar, photo
/// recommendations, sortable per-app list, Hidden Apps, and system rows.
struct DeviceStorageView: View {
    @Environment(SettingsStore.self) private var store
    @State private var appsStore = StorageAppsStore.shared
    @State private var searchText = ""
    @State private var sort: StorageSort = .size
    @State private var confirmEmpty = false
    /// iOS shows the first rows and hides the rest behind "See All Apps".
    @State private var showAllApps = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var deviceName: String { isPad ? "iPad" : "iPhone" }
    private var osName: String { isPad ? "iPadOS" : "iOS" }
    private var settings: MockStorageSettings { store.storage }

    /// Every row of the list, Photos included.
    ///
    /// Detected apps (real name and icon read from the device) are merged
    /// with the apps added by hand in the hidden Storage panel; anything
    /// switched off there is left out. Falls back to the mock catalog when
    /// nothing else is available.
    private var allApps: [StorageEntry] {
        var entries: [StorageEntry] = []
        var seen = Set<String>()

        for app in appsStore.customApps where !appsStore.hiddenBundleIDs.contains(app.bundleID) {
            guard seen.insert(app.bundleID).inserted else { continue }
            let icon: StorageIcon = appsStore.icon(for: app.bundleID).map { StorageIcon.custom($0) }
                ?? .app(bundleID: app.bundleID, symbol: "app.fill", tint: "8E8E93")
            entries.append(StorageEntry(id: app.bundleID, name: app.name, icon: icon,
                                        bytes: app.bundleID == MockStorageCatalog.photosID ? photosBytes : app.bytes,
                                        lastUsed: app.lastUsed,
                                        version: app.version, publisher: app.publisher,
                                        appBytes: app.appBytes))
        }

        if store.useRealApps, let installed = InstalledAppsReader.visibleApps {
            for app in installed where !appsStore.hiddenBundleIDs.contains(app.bundleID) {
                guard seen.insert(app.bundleID).inserted else { continue }
                entries.append(StorageEntry(
                    id: app.bundleID,
                    name: app.name,
                    icon: .app(bundleID: app.bundleID, symbol: "app.fill", tint: "8E8E93"),
                    bytes: app.bundleID == MockStorageCatalog.photosID
                        ? photosBytes
                        : InstalledAppsReader.mockBytes(for: app.bundleID),
                    lastUsed: InstalledAppsReader.mockLastUsed(for: app.bundleID)
                ))
            }
        }

        if entries.isEmpty {
            return [MockStorageCatalog.photosRow(gb: settings.photosGB)] + MockStorageCatalog.apps
        }
        return entries
    }

    /// Applications category: everything except the Photos row.
    private var applicationsBytes: Int64 {
        allApps.filter { $0.id != MockStorageCatalog.photosID }.reduce(0) { $0 + $1.bytes }
    }
    private var photosBytes: Int64 { MockStorageCatalog.gb(settings.photosGB) }
    private var osBytes: Int64 { MockStorageCatalog.gb(settings.osGB) }
    private var systemBytes: Int64 { MockStorageCatalog.gb(settings.systemDataGB) }
    private var totalBytes: Int64 { MockStorageCatalog.gb(settings.totalGB) }
    private var usedBytes: Int64 { applicationsBytes + photosBytes + osBytes + systemBytes }
    private var freeBytes: Int64 { max(0, totalBytes - usedBytes) }

    private var visibleApps: [StorageEntry] {
        let filtered = searchText.isEmpty
            ? allApps
            : allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sort {
        case .size: return filtered.sorted { $0.bytes > $1.bytes }
        case .name: return filtered.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .lastUsed: return filtered.sorted { ($0.lastUsedRank, -$0.bytes) < ($1.lastUsedRank, -$1.bytes) }
        }
    }

    /// First 20 rows until "See All Apps" is tapped; search always shows all.
    private var listedApps: [StorageEntry] {
        guard searchText.isEmpty, !showAllApps else { return visibleApps }
        return Array(visibleApps.prefix(20))
    }
    private var canShowMore: Bool {
        searchText.isEmpty && !showAllApps && visibleApps.count > 20
    }

    private var showsRecommendations: Bool {
        settings.showRecommendations && (settings.reviewPhotosEnabled || settings.recentlyDeletedEnabled)
    }

    var body: some View {
        CustomList(title: "\(deviceName) Storage", topPadding: true) {
            if searchText.isEmpty {
                usageCard
                if showsRecommendations {
                    recommendations
                }
            }

            // MARK: App list
            Section {
                ForEach(listedApps) { entry in
                    RouteLink("Storage/App/\(entry.id)") {
                        AppStorageDetailView(entry: entry)
                    } label: {
                        appRow(entry)
                    }
                }
                if canShowMore {
                    Button("See All Apps") {
                        withAnimation { showAllApps = true }
                    }
                }
            } header: {
                HStack {
                    Spacer()
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(StorageSort.allCases, id: \.self) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sort.title)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.body)
                        .foregroundStyle(.blue)
                    }
                }
                .textCase(nil)
            }

            if searchText.isEmpty {
                // MARK: Hidden Apps (authenticates first, then pushes — like iOS)
                Section {
                    HiddenAppsRow(cardStyle: true) {
                        HStack(spacing: 12) {
                            glyphTile("square.dashed", tint: Color(.systemGray2))
                            Text("Hidden Apps")
                        }
                    }
                }

                // MARK: System rows
                Section {
                    RouteLink("Storage/OS") {
                        StorageSystemDetailView(
                            title: osName,
                            bytes: osBytes,
                            text: "\(osName) includes the operating system, its built-in apps, and system resources required for your \(deviceName) to work. Its size can vary between devices and software versions."
                        )
                    } label: {
                        systemRow(osName, osBytes)
                    }
                    RouteLink("Storage/SystemData") {
                        StorageSystemDetailView(
                            title: "System Data",
                            bytes: systemBytes,
                            text: "System Data includes caches, logs, and other resources currently in use by the system. This size fluctuates according to system needs."
                        )
                    } label: {
                        systemRow("System Data", systemBytes)
                    }
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: UIDevice.iPhone ? .automatic : .toolbar,
            prompt: "Applications"
        )
        .confirmationDialog("Empty “Recently Deleted”?", isPresented: $confirmEmpty, titleVisibility: .visible) {
            Button("Empty", role: .destructive) {
                store.storage.recentlyDeletedEnabled = false
            }
        } message: {
            Text("This will permanently delete all photos and videos kept in the “Recently Deleted” album.")
        }
    }

    // MARK: Usage card
    private var usageCard: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(deviceName)
                    Spacer()
                    Text("\(MockStorageCatalog.format(usedBytes)) of \(MockStorageCatalog.format(totalBytes)) used")
                        .foregroundStyle(.secondary)
                }
                usageBar
                    .frame(height: 20)
                HStack(spacing: 12) {
                    legend(Color(.systemRed), "Applications")
                    legend(Color(.systemOrange), "Photos")
                    legend(Color(.systemGray), osName)
                    legend(Color(.systemGray3), "System Data")
                }
                .font(.footnote)
            }
            .padding(.vertical, 6)
        }
    }

    private var usageBar: some View {
        GeometryReader { geo in
            let total = Double(max(totalBytes, 1))
            HStack(spacing: 2) {
                segment(Color(.systemRed), Double(applicationsBytes) / total, geo.size.width)
                segment(Color(.systemOrange), Double(photosBytes) / total, geo.size.width)
                segment(Color(.systemGray), Double(osBytes) / total, geo.size.width)
                segment(Color(.systemGray3), Double(systemBytes) / total, geo.size.width)
                ZStack(alignment: .trailing) {
                    Rectangle().fill(Color(uiColor: .systemGroupedBackground))
                    Text(MockStorageCatalog.format(freeBytes))
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.trailing, 8)
                }
                .frame(maxWidth: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        }
    }

    private func segment(_ color: Color, _ fraction: Double, _ width: CGFloat) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: max(0, width * min(max(fraction, 0), 1)))
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).foregroundStyle(.secondary)
        }
    }

    // MARK: Recommendations
    @ViewBuilder
    private var recommendations: some View {
        Section {} header: {
            HStack {
                Text("Recommendations")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                RouteLink("Storage/Recommendations") {
                    StorageRecommendationsView()
                } label: {
                    Text("Show All").foregroundStyle(.blue)
                }
            }
            .textCase(nil)
        }

        if settings.reviewPhotosEnabled {
            Section {
                RouteLink("Storage/ReviewPhotos") {
                    StorageRecommendationDetailView(
                        title: "Review Your Photos & Videos",
                        text: "See photos and videos taking up storage in the Photos app and consider deleting them.",
                        saving: MockStorageCatalog.gb(settings.reviewPhotosSaveGB)
                    )
                } label: {
                    HStack(spacing: 12) {
                        StorageIconView(icon: .app(bundleID: MockStorageCatalog.photosID, symbol: "photo.on.rectangle.angled", tint: "FFFFFF"))
                        Text("Review Your Photos & Videos")
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] + 41 }
                Text("Save up to \(MockStorageCatalog.format(MockStorageCatalog.gb(settings.reviewPhotosSaveGB))). See photos and videos taking up storage in the Photos app and consider deleting them.")
                    .foregroundStyle(.secondary)
                    .padding(.leading, 41)
            }
        }

        if settings.recentlyDeletedEnabled {
            Section {
                HStack(spacing: 12) {
                    StorageIconView(icon: .app(bundleID: MockStorageCatalog.photosID, symbol: "photo.on.rectangle.angled", tint: "FFFFFF"))
                    Text("“Recently Deleted” Album")
                    Spacer()
                    Button("Empty") { confirmEmpty = true }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.blue)
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] + 41 }
                Text("Save up to \(MockStorageCatalog.format(MockStorageCatalog.mb(settings.recentlyDeletedSaveMB))). This will permanently delete all photos and videos kept in the “Recently Deleted” album.")
                    .foregroundStyle(.secondary)
                    .padding(.leading, 41)
            }
        }
    }

    // MARK: Rows
    private func appRow(_ entry: StorageEntry) -> some View {
        HStack(spacing: 12) {
            StorageIconView(icon: entry.icon)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if entry.offloaded {
                        Image(systemName: "icloud.and.arrow.down")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if !entry.name.isEmpty {
                        Text(entry.name)
                    }
                }
                if let lastUsed = entry.lastUsed {
                    Text("Last used: \(lastUsed)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(MockStorageCatalog.format(entry.bytes))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, entry.lastUsed == nil ? 0 : 2)
    }

    private func systemRow(_ title: String, _ bytes: Int64) -> some View {
        HStack(spacing: 12) {
            // Real Settings app icon on device (gray gear), like iOS.
            StorageIconView(icon: .app(bundleID: "com.apple.Preferences", symbol: "gearshape.fill", tint: "8E8E93"))
            Text(title)
            Spacer()
            Text(MockStorageCatalog.format(bytes)).foregroundStyle(.secondary)
        }
    }

    private func glyphTile(_ symbol: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6.5, style: .continuous).fill(tint)
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 29, height: 29)
    }
}

/// Row icon: real installed app icon when available, otherwise a tinted
/// glyph tile. `multi` draws grouped-developer clusters.
struct StorageIconView: View {
    let icon: StorageIcon

    var body: some View {
        switch icon {
        case .app(let bundleID, let symbol, let tint):
            if let bundleID, let image = UIImage.installedAppIcon(forBundleID: bundleID) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 29, height: 29)
                    .clipShape(RoundedRectangle(cornerRadius: 6.5, style: .continuous))
            } else {
                tile(symbol, tint, side: 29)
            }
        case .custom(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 29, height: 29)
                .clipShape(RoundedRectangle(cornerRadius: 6.5, style: .continuous))
        case .multi(let items):
            if items.count <= 2 {
                HStack(spacing: 3) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        tile(item.symbol, item.tint, side: 20)
                    }
                }
                .frame(height: 29)
            } else {
                LazyVGrid(columns: [GridItem(.fixed(13), spacing: 3), GridItem(.fixed(13), spacing: 3)], spacing: 3) {
                    ForEach(Array(items.prefix(4).enumerated()), id: \.offset) { _, item in
                        tile(item.symbol, item.tint, side: 13)
                    }
                }
                .frame(width: 29, height: 29)
            }
        }
    }

    private func tile(_ symbol: String, _ tint: String, side: CGFloat) -> some View {
        let color = Color.fromHex(tint)
        let isWhite = tint.uppercased() == "FFFFFF"
        return ZStack {
            RoundedRectangle(cornerRadius: side * 0.2237, style: .continuous)
                .fill(LinearGradient(colors: [color.opacity(0.85), color], startPoint: .top, endPoint: .bottom))
            Image(systemName: symbol)
                .font(.system(size: side * 0.5, weight: .semibold))
                .foregroundStyle(isWhite ? Color.orange : Color.white)
        }
        .frame(width: side, height: side)
    }
}

/// [Device] Storage > [App]
struct AppStorageDetailView: View {
    let entry: StorageEntry
    @State private var confirmDelete = false

    private var deviceName: String { UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone" }

    private var appSize: Int64 { min(entry.bytes, entry.appBytes ?? Int64(Double(entry.bytes) * 0.35)) }
    private var dataSize: Int64 { max(0, entry.bytes - appSize) }

    var body: some View {
        CustomList(title: entry.name, topPadding: true) {
            // Icon, then name / version / seller — the version is printed bare
            // ("1.0.57"), exactly as Settings does.
            Section {
                HStack(spacing: 14) {
                    headerIcon
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.name)
                        if let version = entry.version, !version.isEmpty {
                            Text(version)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let publisher = entry.publisher, !publisher.isEmpty {
                            Text(publisher)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                }
                .padding(.vertical, 6)
                LabeledContent("App Size", value: MockStorageCatalog.format(appSize))
                LabeledContent("Documents & Data", value: MockStorageCatalog.format(dataSize))
            }

            Section {
                Button {} label: {
                    Text(entry.offloaded ? "Reinstall App" : "Offload App")
                        .frame(maxWidth: .infinity)
                }
            } footer: {
                Text(entry.offloaded
                     ? "This app is offloaded. Reinstalling it will place back your data if the app is still available for download."
                     : "This will free up storage used by the app, but keep its documents and data. Reinstalling the app will place back your data if the app is still available for download.")
            }

            Section {
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Text("Delete App")
                        .frame(maxWidth: .infinity)
                }
            } footer: {
                Text("This will delete the app and all related data from this \(deviceName). This action can’t be undone.")
            }
        }
        .confirmationDialog("Delete “\(entry.name)”?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete App", role: .destructive) {}
        } message: {
            Text("Deleting this app will also delete its documents and data.")
        }
    }

    /// App Store artwork is drawn at full size rather than scaled up from the
    /// list icon, so it stays sharp.
    @ViewBuilder
    private var headerIcon: some View {
        if case .custom(let image) = entry.icon {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 11.25, style: .continuous))
        } else {
            StorageIconView(icon: entry.icon)
                .scaleEffect(50.0 / 29.0)
                .frame(width: 50, height: 50)
        }
    }
}

/// [Device] Storage > Recommendations (Show All)
struct StorageRecommendationsView: View {
    @Environment(SettingsStore.self) private var store

    var body: some View {
        CustomList(title: "Recommendations", topPadding: true) {
            if store.storage.reviewPhotosEnabled {
                Section {
                    RouteLink("Storage/Recommendations/ReviewPhotos") {
                        StorageRecommendationDetailView(
                            title: "Review Your Photos & Videos",
                            text: "See photos and videos taking up storage in the Photos app and consider deleting them.",
                            saving: MockStorageCatalog.gb(store.storage.reviewPhotosSaveGB)
                        )
                    } label: {
                        HStack(spacing: 12) {
                            StorageIconView(icon: .app(bundleID: MockStorageCatalog.photosID, symbol: "photo.on.rectangle.angled", tint: "FFFFFF"))
                            Text("Review Your Photos & Videos")
                        }
                    }
                } footer: {
                    Text("Save up to \(MockStorageCatalog.format(MockStorageCatalog.gb(store.storage.reviewPhotosSaveGB))).")
                }
            }
            if store.storage.recentlyDeletedEnabled {
                Section {
                    HStack(spacing: 12) {
                        StorageIconView(icon: .app(bundleID: MockStorageCatalog.photosID, symbol: "photo.on.rectangle.angled", tint: "FFFFFF"))
                        Text("“Recently Deleted” Album")
                        Spacer()
                        Button("Empty") { store.storage.recentlyDeletedEnabled = false }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.blue)
                    }
                } footer: {
                    Text("Save up to \(MockStorageCatalog.format(MockStorageCatalog.mb(store.storage.recentlyDeletedSaveMB))).")
                }
            }
            if !store.storage.reviewPhotosEnabled && !store.storage.recentlyDeletedEnabled {
                ContentUnavailableView("No Recommendations", systemImage: "checkmark.circle")
                    .listRowBackground(Color.clear)
            }
        }
    }
}

/// Simple explanatory page for a single recommendation.
struct StorageRecommendationDetailView: View {
    let title: String
    let text: String
    let saving: Int64

    var body: some View {
        CustomList(title: title, topPadding: true) {
            Section {
                LabeledContent("Potential Savings", value: MockStorageCatalog.format(saving))
            } footer: {
                Text(text)
            }
            Section {
                Button("Open Photos") {
                    if let url = URL(string: "photos-redirect://") { UIApplication.shared.open(url) }
                }
            }
        }
    }
}

/// [Device] Storage > iPadOS / System Data
struct StorageSystemDetailView: View {
    let title: String
    let bytes: Int64
    let text: String

    var body: some View {
        CustomList(title: title, topPadding: true) {
            Section {
                LabeledContent(title, value: MockStorageCatalog.format(bytes))
            } footer: {
                Text(text)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeviceStorageView()
    }
    .environment(SettingsStore.shared)
    .environment(PrimarySettingsListModel())
}
