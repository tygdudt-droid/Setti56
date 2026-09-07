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

/// Bundle IDs the icon probe checks when the system app list is unavailable.
///
/// Add a line here to make an app show up in Settings > Storage — only apps
/// that are really installed pass the probe, so extra entries are harmless.
enum KnownAppCatalog {
    static let entries: [(bundleID: String, name: String)] = [
        // Apple
        ("com.apple.AppStore", "App Store"),
        ("com.apple.iBooks", "Books"),
        ("com.apple.calculator", "Calculator"),
        ("com.apple.mobilecal", "Calendar"),
        ("com.apple.camera", "Camera"),
        ("com.apple.clips", "Clips"),
        ("com.apple.mobiletimer", "Clock"),
        ("com.apple.compass", "Compass"),
        ("com.apple.MobileAddressBook", "Contacts"),
        ("com.apple.DocumentsApp", "Files"),
        ("com.apple.facetime", "FaceTime"),
        ("com.apple.findmy", "Find My"),
        ("com.apple.Fitness", "Fitness"),
        ("com.apple.freeform", "Freeform"),
        ("com.apple.mobilegarageband", "GarageBand"),
        ("com.apple.Health", "Health"),
        ("com.apple.Home", "Home"),
        ("com.apple.iMovie", "iMovie"),
        ("com.apple.Keynote", "Keynote"),
        ("com.apple.Magnifier", "Magnifier"),
        ("com.apple.mobilemail", "Mail"),
        ("com.apple.Maps", "Maps"),
        ("com.apple.measure", "Measure"),
        ("com.apple.MobileSMS", "Messages"),
        ("com.apple.Music", "Music"),
        ("com.apple.news", "News"),
        ("com.apple.mobilenotes", "Notes"),
        ("com.apple.Numbers", "Numbers"),
        ("com.apple.Pages", "Pages"),
        ("com.apple.Passwords", "Passwords"),
        ("com.apple.mobilephone", "Phone"),
        ("com.apple.mobileslideshow", "Photos"),
        ("com.apple.podcasts", "Podcasts"),
        ("com.apple.Preview", "Preview"),
        ("com.apple.reminders", "Reminders"),
        ("com.apple.mobilesafari", "Safari"),
        ("com.apple.shortcuts", "Shortcuts"),
        ("com.apple.stocks", "Stocks"),
        ("com.apple.tips", "Tips"),
        ("com.apple.Translate", "Translate"),
        ("com.apple.tv", "TV"),
        ("com.apple.VoiceMemos", "Voice Memos"),
        ("com.apple.Passbook", "Wallet"),
        ("com.apple.weather", "Weather"),
        ("com.apple.Preferences", "Settings"),
        ("com.apple.Bridge", "Watch"),
        ("com.apple.PhotoBooth", "Photo Booth"),
        ("com.apple.SwiftPlaygrounds", "Swift Playgrounds"),
        ("com.apple.journal", "Journal"),
        ("com.apple.sharekit", "Share"),

        // Messaging and social
        ("ph.telegra.Telegraph", "Telegram"),
        ("net.whatsapp.WhatsApp", "WhatsApp"),
        ("com.burbn.instagram", "Instagram"),
        ("com.facebook.Facebook", "Facebook"),
        ("com.facebook.Messenger", "Messenger"),
        ("com.atebits.Tweetie2", "X"),
        ("com.zhiliaoapp.musically", "TikTok"),
        ("com.toyopagroup.picaboo", "Snapchat"),
        ("com.hammerandchisel.discord", "Discord"),
        ("com.reddit.Reddit", "Reddit"),
        ("com.linkedin.LinkedIn", "LinkedIn"),
        ("com.pinterest", "Pinterest"),
        ("com.viber", "Viber"),
        ("com.skype.skype", "Skype"),
        ("ir.eitaa.messenger", "Eitaa"),
        ("ir.nasim", "Bale"),
        ("im.sorush.messenger", "Soroush Plus"),
        ("ir.medu.shad", "Shad"),
        ("com.rubika.app", "Rubika"),
        ("ir.namasha", "Namasho"),
        ("com.bmi.bam", "Bam"),
        ("ir.aparat", "Aparat"),
        ("com.divar", "Divar"),
        ("ir.snapp.passenger", "Snapp"),
        ("com.digikala", "Digikala"),
        ("ir.filimo", "Filimo"),

        // Media and streaming
        ("com.google.ios.youtube", "YouTube"),
        ("com.netflix.Netflix", "Netflix"),
        ("com.spotify.client", "Spotify"),
        ("com.soundcloud.TouchApp", "SoundCloud"),
        ("org.videolan.vlc-ios", "VLC"),
        ("com.instashot.ios", "InShot"),
        ("com.google.Meet", "Meet"),
        ("com.google.Gmail", "Gmail"),
        ("com.google.chrome.ios", "Chrome"),
        ("com.google.Maps", "Google Maps"),
        ("com.google.Drive", "Drive"),
        ("com.google.photos", "Google Photos"),
        ("com.google.b612", "Google"),
        ("com.microsoft.Office.Word", "Word"),
        ("com.microsoft.Office.Excel", "Excel"),
        ("com.microsoft.Office.Powerpoint", "PowerPoint"),
        ("com.microsoft.skydrive", "OneDrive"),
        ("com.microsoft.msedge", "Edge"),
        ("com.dropbox.Dropbox", "Dropbox"),
        ("com.adobe.PSMobile", "Photoshop Express"),
        ("com.adobe.lrmobile", "Lightroom"),
        ("com.canva.canvaeditor", "Canva"),
        ("com.figma.figma", "Figma"),
        ("com.picsart.studio", "Picsart"),
        ("com.lightricks.Facetune", "Facetune"),

        // Games
        ("com.activision.callofduty.shooter", "Call of Duty"),
        ("com.rockstar.gtavc", "GTA: Vice City"),
        ("com.miniclip.8ballpoolmult", "8 Ball Pool"),
        ("com.supercell.magic", "Clash of Clans"),
        ("com.supercell.laser", "Clash Royale"),
        ("com.supercell.scroll", "Brawl Stars"),
        ("com.innersloth.amongus", "Among Us"),
        ("com.mojang.minecraftpe", "Minecraft"),
        ("com.ea.ios.apexlegendsmobile", "Apex Legends"),
        ("com.tencent.ig", "PUBG MOBILE"),
        ("com.dts.freefireth", "Free Fire"),
        ("com.robtopx.geometryjump", "Geometry Dash"),
        ("com.amanotes.magictiles3", "Magic Tiles 3"),
        ("com.fungames.sniper3d", "Sniper 3D"),
        ("com.king.candycrushsaga", "Candy Crush Saga"),
        ("com.hokm.king", "Hokm King"),

        // Utilities and VPN
        ("com.nordvpn.ios", "NordVPN"),
        ("com.expressvpn.ExpressVPN", "ExpressVPN"),
        ("com.turbovpn.ios", "Turbo VPN"),
        ("com.vpnify.ios", "vpnify"),
        ("com.xvpn.ios", "X-VPN"),
        ("com.vpn360.ios", "VPN 360"),
        ("com.psiphon3.ios", "Psiphon"),
        ("com.v2box.app", "V2BOX"),
        ("com.gbox.app", "GBox"),
        ("net.shadowsocks.ShadowsocksX", "Shadowrocket"),
        ("com.getdropbox.Dropbox", "Files+"),
        ("com.readdle.PDFExpert5", "PDF Expert"),
        ("com.if.Notion", "Notion"),
        ("com.evernote.iPhone.Evernote", "Evernote"),
        ("com.duolingo.DuolingoMobile", "Duolingo"),
        ("com.amazon.Amazon", "Amazon"),
        ("com.ebay.iphone", "eBay"),
        ("com.paypal.PPClient", "PayPal"),
        ("com.binance.dev", "Binance"),
        ("com.zoom.videomeetings", "Zoom")
    ]
}

/// Builds the installed-app list.
///
/// Three strategies, tried in order:
/// 1. `LSApplicationWorkspace` — the full system list, when LaunchServices
///    answers (it returns nothing for apps without the private entitlement).
/// 2. `SpringBoardServices` — the Home Screen list, same caveat.
/// 3. **Icon probe** — asks Preferences.framework for the icon of every
///    bundle ID in `KnownAppCatalog`; only installed apps return a real one.
///    This is the path that works on a normal dev-signed build.
///
/// Every step is guarded at runtime, so an OS change degrades to the next
/// strategy (and finally to the mock catalog) instead of crashing.
///
/// - Warning: Private API, like the icon lookup this project already uses.
enum InstalledAppsReader {
    enum Source: String {
        case launchServices = "LaunchServices"
        case springBoard = "SpringBoard"
        case iconProbe = "installed-icon probe"
        case unavailable = "unavailable"
    }

    /// Runs once, lazily, on first access.
    static let result: (apps: [InstalledApp], source: Source) = load()

    static var visibleApps: [InstalledApp]? {
        result.apps.isEmpty ? nil : result.apps
    }

    /// Short line for the Mock Configuration footer.
    static var diagnostic: String {
        result.apps.isEmpty
            ? "No installed apps could be read on this device, so the mock list is used."
            : "Found \(result.apps.count) installed apps via \(result.source.rawValue)."
    }

    private static func load() -> ([InstalledApp], Source) {
        if let apps = launchServicesApps(), !apps.isEmpty { return (apps, .launchServices) }
        if let apps = springBoardApps(), !apps.isEmpty { return (apps, .springBoard) }
        let probed = probedApps()
        if !probed.isEmpty { return (probed, .iconProbe) }
        return ([], .unavailable)
    }

    // MARK: 1. LaunchServices

    private static func launchServicesApps() -> [InstalledApp]? {
        load("/System/Library/Frameworks/CoreServices.framework/CoreServices")
        load("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices")

        let defaultSel = NSSelectorFromString("defaultWorkspace")
        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace"),
              class_getClassMethod(workspaceClass, defaultSel) != nil,
              let workspace = (workspaceClass as AnyObject).perform(defaultSel)?
                  .takeUnretainedValue() as? NSObject
        else { return nil }

        var proxies: [NSObject] = []
        for name in ["allApplications", "allInstalledApplications"] {
            let selector = NSSelectorFromString(name)
            guard workspace.responds(to: selector),
                  let list = workspace.perform(selector)?.takeUnretainedValue() as? [NSObject],
                  !list.isEmpty
            else { continue }
            proxies = list
            break
        }
        guard !proxies.isEmpty else { return nil }

        var seen = Set<String>()
        var result: [InstalledApp] = []
        for proxy in proxies {
            guard let bundleID = string(proxy, "applicationIdentifier"),
                  !bundleID.isEmpty, seen.insert(bundleID).inserted,
                  !isHidden(proxy), !isNoise(bundleID)
            else { continue }
            let name = string(proxy, "localizedName") ?? bundleID
            let type = string(proxy, "applicationType") ?? "User"
            result.append(InstalledApp(bundleID: bundleID, name: name, isSystem: type == "System"))
        }
        return result
    }

    // MARK: 2. SpringBoardServices

    private static func springBoardApps() -> [InstalledApp]? {
        guard let handle = load("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"),
              let identifiersSymbol = dlsym(handle, "SBSCopyApplicationDisplayIdentifiers")
        else { return nil }

        typealias IdentifiersFunction = @convention(c) (ObjCBool, ObjCBool) -> Unmanaged<CFArray>?
        let copyIdentifiers = unsafeBitCast(identifiersSymbol, to: IdentifiersFunction.self)
        guard let rawList = copyIdentifiers(ObjCBool(false), ObjCBool(false))?.takeRetainedValue(),
              let identifiers = (rawList as NSArray) as? [String],
              !identifiers.isEmpty
        else { return nil }

        typealias NameFunction = @convention(c) (CFString) -> Unmanaged<CFString>?
        let copyName = dlsym(handle, "SBSCopyLocalizedApplicationNameForDisplayIdentifier")
            .map { unsafeBitCast($0, to: NameFunction.self) }

        return identifiers.compactMap { bundleID in
            guard !isNoise(bundleID) else { return nil }
            let rawName: CFString? = copyName?(bundleID as CFString)?.takeRetainedValue()
            let name = rawName as String?
            return InstalledApp(bundleID: bundleID,
                                name: name ?? bundleID,
                                isSystem: bundleID.hasPrefix("com.apple."))
        }
    }

    // MARK: 3. Icon probe

    /// Icon returned for a bundle ID that is not installed; used to tell a
    /// real icon apart from the generic placeholder.
    private static let placeholderIcon: Data? = {
        UIImage.icon(forBundleID: "com.example.definitely.not.installed.\(UUID().uuidString)")?.pngData()
    }()

    /// True when Preferences.framework has a real icon for this bundle ID.
    static func isInstalled(_ bundleID: String) -> Bool {
        guard let image = UIImage.icon(forBundleID: bundleID), image.size.width > 0 else { return false }
        guard let data = image.pngData() else { return false }
        if let placeholderIcon, data == placeholderIcon { return false }
        return true
    }

    private static func probedApps() -> [InstalledApp] {
        KnownAppCatalog.entries.compactMap { entry in
            guard isInstalled(entry.bundleID) else { return nil }
            return InstalledApp(bundleID: entry.bundleID,
                                name: entry.name,
                                isSystem: entry.bundleID.hasPrefix("com.apple."))
        }
    }

    // MARK: Runtime helpers

    @discardableResult
    private static func load(_ path: String) -> UnsafeMutableRawPointer? {
        if let handle = dlopen(path, RTLD_NOLOAD) { return handle }
        return dlopen(path, RTLD_NOW)
    }

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
