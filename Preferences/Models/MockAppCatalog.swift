import SwiftUI
import ObjectiveC

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
        MockApp(bundleID: "com.mock.chirp", name: "Chirp", icon: "feather", tintHex: "1D9BF0", category: .social, installedAt: .daysAgo(40)),
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

// MARK: - Real installed apps

/// One app actually installed on this device.
struct InstalledApp: Identifiable, Hashable {
    let bundleID: String
    let name: String
    let isSystem: Bool
    var id: String { bundleID }
}

/// Reads the installed-app list through `LSApplicationWorkspace`, the same
/// kind of private lookup this project already uses for Settings icons.
///
/// Every step is guarded with a runtime check, so a future OS change makes
/// `apps` return `nil` — callers then fall back to the mock catalog — rather
/// than raising an unrecognized-selector exception.
///
/// - Warning: Private API. Do not reuse this in a shipping app.
enum InstalledAppsReader {
    /// Runs once, lazily, on first access.
    static let apps: [InstalledApp]? = load()

    /// Real apps if available, otherwise nil.
    static var visibleApps: [InstalledApp]? {
        guard let apps, !apps.isEmpty else { return nil }
        return apps
    }

    private static func load() -> [InstalledApp]? {
        let defaultSel = NSSelectorFromString("defaultWorkspace")
        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace"),
              class_getClassMethod(workspaceClass, defaultSel) != nil,
              let workspace = (workspaceClass as AnyObject).perform(defaultSel)?
                  .takeUnretainedValue() as? NSObject
        else { return nil }

        let allSel = NSSelectorFromString("allApplications")
        guard workspace.responds(to: allSel),
              let proxies = workspace.perform(allSel)?.takeUnretainedValue() as? [NSObject]
        else { return nil }

        var seen = Set<String>()
        var result: [InstalledApp] = []
        for proxy in proxies {
            guard let bundleID = string(proxy, "applicationIdentifier"),
                  !bundleID.isEmpty,
                  !seen.contains(bundleID),
                  !isHidden(proxy),
                  !isNoise(bundleID)
            else { continue }
            seen.insert(bundleID)
            let name = string(proxy, "localizedName") ?? bundleID
            let type = string(proxy, "applicationType") ?? "User"
            result.append(InstalledApp(bundleID: bundleID, name: name, isSystem: type == "System"))
        }
        return result.isEmpty ? nil : result
    }

    // MARK: Runtime helpers

    private static func string(_ object: NSObject, _ name: String) -> String? {
        let selector = NSSelectorFromString(name)
        guard object.responds(to: selector) else { return nil }
        return object.perform(selector)?.takeUnretainedValue() as? String
    }

    /// SpringBoard marks setup assistants and demo apps with a "hidden" tag.
    private static func isHidden(_ proxy: NSObject) -> Bool {
        let selector = NSSelectorFromString("appTags")
        guard proxy.responds(to: selector),
              let tags = proxy.perform(selector)?.takeUnretainedValue() as? [String]
        else { return false }
        return tags.contains("hidden")
    }

    /// Internal bundles that never appear in Settings > Storage.
    private static func isNoise(_ bundleID: String) -> Bool {
        let lower = bundleID.lowercased()
        return lower.hasPrefix("com.apple.webapp")
            || lower.contains(".internal")
            || lower.contains("diagnostic")
            || lower.hasSuffix(".appex")
    }

    // MARK: Deterministic mock numbers

    /// Stable per-bundle hash so sizes never change between launches.
    private static func hash(_ text: String) -> UInt64 {
        var value: UInt64 = 0xcbf29ce484222325
        for byte in text.utf8 {
            value = (value ^ UInt64(byte)) &* 0x100000001b3
        }
        return value
    }

    /// Plausible size for an app: a few very large, most small.
    static func mockBytes(for bundleID: String) -> Int64 {
        let h = hash(bundleID)
        let bucket = h % 100
        let spread = Double(h >> 8 & 0xFFFF) / Double(0xFFFF)
        let gb: Double
        switch bucket {
        case 0..<4:   gb = 8 + spread * 34        // 8–42 GB
        case 4..<12:  gb = 1.5 + spread * 6       // 1.5–7.5 GB
        case 12..<40: gb = 0.15 + spread * 1.2    // 150 MB–1.3 GB
        case 40..<80: gb = 0.02 + spread * 0.12   // 20–140 MB
        default:      gb = 0.00002 + spread * 0.0008
        }
        return Int64(gb * 1_000_000_000)
    }

    /// Stable "Last used" line; some apps show none, like iOS.
    static func mockLastUsed(for bundleID: String) -> String? {
        let h = hash(bundleID) >> 24
        switch h % 6 {
        case 0, 1: return "Today"
        case 2: return "Yesterday"
        case 3: return "\(Int(h % 6) + 2) days ago"
        default: return nil
        }
    }
}
