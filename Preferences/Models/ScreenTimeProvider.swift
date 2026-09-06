import SwiftUI
import Observation

/// Screen Time usage categories. Colors match iPadOS 26 (Social blue,
/// Games cyan, Other orange).
enum ScreenTimeCategory: String, CaseIterable, Codable {
    case social = "Social"
    case entertainment = "Entertainment"
    case productivity = "Productivity & Finance"
    case creativity = "Creativity"
    case games = "Games"
    case information = "Information & Reading"
    case other = "Other"

    var color: Color {
        switch self {
        case .social: return Color(.systemBlue)
        case .entertainment: return Color(.systemPink)
        case .productivity: return Color(red: 0.42, green: 0.45, blue: 0.68)
        case .creativity: return Color(.systemPurple)
        case .games: return ScreenTimePalette.cyan
        case .information: return Color(.systemMint)
        case .other: return Color(.systemOrange)
        }
    }
}

enum ScreenTimePalette {
    /// Bar color on the Screen Time overview card and for pickups.
    static let cyan = Color(red: 0.19, green: 0.83, blue: 0.90)
    static let average = Color(.systemGreen)
    static let notification = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let dimmedBar = Color(white: 0.24)
    static let usageTrack = Color(white: 0.28)
}

/// One app in a Screen Time list (usage / pickups / notifications).
struct STApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleID: String?
    let symbol: String
    let tint: String
    let category: ScreenTimeCategory

    var icon: StorageIcon { .app(bundleID: bundleID, symbol: symbol, tint: tint) }

    static let telegram = STApp(id: "telegram", name: "Telegram", bundleID: "ph.telegra.Telegraph", symbol: "paperplane.fill", tint: "2AABEE", category: .social)
    static let meet = STApp(id: "meet", name: "Meet", bundleID: nil, symbol: "video.fill", tint: "F4B400", category: .social)
    static let cod = STApp(id: "cod", name: "Call of Duty", bundleID: "com.activision.callofduty.shooter", symbol: "scope", tint: "1C1C1E", category: .games)
    static let safari = STApp(id: "safari", name: "Safari", bundleID: "com.apple.mobilesafari", symbol: "safari.fill", tint: "0A84FF", category: .other)
    static let gta = STApp(id: "gta", name: "GTA: Vice City", bundleID: nil, symbol: "car.fill", tint: "D9418C", category: .games)
    static let settings = STApp(id: "settings", name: "Settings", bundleID: "com.apple.Preferences", symbol: "gearshape.fill", tint: "8E8E93", category: .other)
    static let settingsOld = STApp(id: "settings2", name: "Settings", bundleID: nil, symbol: "gearshape.fill", tint: "8E8E93", category: .other)
    static let gbox = STApp(id: "gbox", name: "GBox", bundleID: nil, symbol: "shippingbox.fill", tint: "34C759", category: .other)
    static let hokm = STApp(id: "hokm", name: "Hokm King", bundleID: nil, symbol: "suit.spade.fill", tint: "B23A48", category: .games)
    static let instagram = STApp(id: "instagram", name: "Instagram", bundleID: "com.burbn.instagram", symbol: "camera.circle.fill", tint: "E1306C", category: .social)
    static let whatsapp = STApp(id: "whatsapp", name: "WhatsApp", bundleID: "net.whatsapp.WhatsApp", symbol: "phone.fill", tint: "25D366", category: .social)
    static let youtube = STApp(id: "youtube", name: "YouTube", bundleID: nil, symbol: "play.fill", tint: "FF0000", category: .other)
}

/// Value paired with an app (minutes, pickups or notifications).
struct STAppValue: Identifiable {
    let app: STApp
    let value: Int
    var id: String { app.id }
}

/// One day of mock Screen Time data.
struct ScreenTimeDay: Identifiable {
    var id: Date { date }
    let date: Date
    /// 24 buckets of minutes per category.
    var hourly: [[ScreenTimeCategory: Int]]
    var pickupsHourly: [Int]
    var notificationsHourly: [Int]
    var mostUsed: [STAppValue]
    var firstUsedAfterPickup: [STAppValue]
    var notificationsByApp: [STAppValue]
    /// Category totals shown in the legend (iOS reports these separately
    /// from the hourly buckets, so they are stored explicitly).
    var categoryTotals: [ScreenTimeCategory: Int]

    var total: Int { hourly.reduce(0) { $0 + $1.values.reduce(0, +) } }
    var pickups: Int { pickupsHourly.reduce(0, +) }
    var notifications: Int { notificationsHourly.reduce(0, +) }
    var firstPickupHour: Int? { pickupsHourly.firstIndex { $0 > 0 } }
    var hasData: Bool { total > 0 || pickups > 0 || notifications > 0 }

    static func empty(_ date: Date) -> ScreenTimeDay {
        ScreenTimeDay(date: date,
                      hourly: Array(repeating: [:], count: 24),
                      pickupsHourly: Array(repeating: 0, count: 24),
                      notificationsHourly: Array(repeating: 0, count: 24),
                      mostUsed: [], firstUsedAfterPickup: [], notificationsByApp: [],
                      categoryTotals: [:])
    }
}

/// Fixed dataset mirroring a real iPad (this week: yesterday + today only).
@MainActor
@Observable
final class ScreenTimeProvider {
    static let shared = ScreenTimeProvider()

    /// The 7 days of the current week in the user's calendar order
    /// (first weekday of the locale first).
    let week: [ScreenTimeDay]
    /// Index of today inside `week`.
    let todayIndex: Int

    var today: ScreenTimeDay { week[todayIndex] }

    /// Week-level numbers (fixed, like the screenshots).
    let weekMostUsed: [STAppValue] = [
        STAppValue(app: .telegram, value: 12 * 60 + 50),
        STAppValue(app: .meet, value: 9 * 60 + 14),
        STAppValue(app: .cod, value: 4 * 60 + 21),
        STAppValue(app: .safari, value: 38),
        STAppValue(app: .gta, value: 35),
        STAppValue(app: .settings, value: 33),
        STAppValue(app: .settingsOld, value: 17),
        STAppValue(app: .gbox, value: 9),
        STAppValue(app: .instagram, value: 8),
        STAppValue(app: .whatsapp, value: 6),
        STAppValue(app: .youtube, value: 4)
    ]
    let weekFirstUsedAfterPickup: [STAppValue] = [
        STAppValue(app: .telegram, value: 17),
        STAppValue(app: .meet, value: 12),
        STAppValue(app: .cod, value: 3),
        STAppValue(app: .safari, value: 2),
        STAppValue(app: .settings, value: 2),
        STAppValue(app: .gta, value: 1)
    ]
    let weekNotificationsByApp: [STAppValue] = [
        STAppValue(app: .hokm, value: 2),
        STAppValue(app: .meet, value: 2),
        STAppValue(app: .telegram, value: 1),
        STAppValue(app: .whatsapp, value: 1)
    ]
    let weekCategoryTotals: [ScreenTimeCategory: Int] = [
        .social: 19 * 60 + 46, .games: 4 * 60 + 22, .other: 1 * 60 + 51
    ]

    var daysWithData: Int { max(1, week.filter(\.hasData).count) }
    var weekTotal: Int { week.reduce(0) { $0 + $1.total } }
    var weekTotalReported: Int { 23 * 60 + 13 }             // "Total Screen Time"
    var dailyAverage: Int { weekTotalReported / daysWithData }
    var weekPickups: Int { week.reduce(0) { $0 + $1.pickups } }
    var averagePickups: Int { Int((Double(weekPickups) / Double(daysWithData)).rounded()) }
    var weekNotifications: Int { week.reduce(0) { $0 + $1.notifications } }
    var averageNotifications: Int { Int((Double(weekNotifications) / Double(daysWithData)).rounded()) }
    var mostPickupsDay: ScreenTimeDay? { week.max { $0.pickups < $1.pickups } }

    /// Short weekday initials in calendar order, e.g. S S M T W T F.
    var weekdayInitials: [String] {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEEE"
        return week.map { f.string(from: $0.date) }
    }

    init() {
        var cal = Calendar.current
        cal.locale = Locale.current
        let todayStart = cal.startOfDay(for: .now)
        let weekday = cal.component(.weekday, from: todayStart)           // 1 = Sunday
        let offset = (weekday - cal.firstWeekday + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -offset, to: todayStart) ?? todayStart
        var days: [ScreenTimeDay] = (0..<7).map { i in
            .empty(cal.date(byAdding: .day, value: i, to: weekStart) ?? weekStart)
        }
        todayIndex = offset
        days[offset] = ScreenTimeProvider.todayData(date: days[offset].date)
        if offset > 0 {
            days[offset - 1] = ScreenTimeProvider.yesterdayData(date: days[offset - 1].date)
        }
        week = days
    }

    // MARK: Fixed data

    private static func todayData(date: Date) -> ScreenTimeDay {
        // Minutes per hour: (social, games, other)
        let h: [(Int, Int, Int)] = [
            (52, 0, 5), (52, 0, 6), (52, 0, 5), (45, 0, 12), (33, 0, 6),     // 00–04
            (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0),           // 05–09
            (10, 0, 2), (58, 0, 0), (42, 18, 0), (38, 22, 0), (34, 22, 4),   // 10–14
            (32, 25, 3), (30, 27, 3), (30, 26, 4), (18, 3, 0), (0, 0, 0),    // 15–19
            (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)                       // 20–23
        ]
        var day = ScreenTimeDay.empty(date)
        day.hourly = h.map { s, g, o in
            var b: [ScreenTimeCategory: Int] = [:]
            if s > 0 { b[.social] = s }
            if g > 0 { b[.games] = g }
            if o > 0 { b[.other] = o }
            return b
        }
        day.pickupsHourly = [1, 1, 1, 1, 3, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1, 1, 3, 1, 0, 0, 0, 0, 0]
        day.notificationsHourly = Array(repeating: 0, count: 24)
        day.mostUsed = [
            STAppValue(app: .telegram, value: 6 * 60 + 31),
            STAppValue(app: .meet, value: 5 * 60 + 13),
            STAppValue(app: .cod, value: 3 * 60 + 41),
            STAppValue(app: .settings, value: 28),
            STAppValue(app: .settingsOld, value: 17),
            STAppValue(app: .gbox, value: 5),
            STAppValue(app: .instagram, value: 4),
            STAppValue(app: .safari, value: 3)
        ]
        day.firstUsedAfterPickup = [
            STAppValue(app: .telegram, value: 7),
            STAppValue(app: .meet, value: 6),
            STAppValue(app: .cod, value: 2),
            STAppValue(app: .safari, value: 1)
        ]
        day.notificationsByApp = []
        day.categoryTotals = [.social: 10 * 60 + 52, .games: 3 * 60 + 41, .other: 51]
        return day
    }

    private static func yesterdayData(date: Date) -> ScreenTimeDay {
        let h: [(Int, Int, Int)] = [
            (40, 0, 4), (48, 0, 5), (50, 0, 5), (44, 0, 6), (20, 0, 4),
            (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (12, 0, 0),
            (35, 0, 3), (52, 0, 4), (48, 0, 5), (44, 3, 5), (46, 4, 4),
            (40, 6, 4), (38, 8, 3), (36, 8, 3), (32, 6, 2), (28, 4, 2),
            (22, 2, 1), (10, 0, 0), (0, 0, 0), (0, 0, 0)
        ]
        var day = ScreenTimeDay.empty(date)
        day.hourly = h.map { s, g, o in
            var b: [ScreenTimeCategory: Int] = [:]
            if s > 0 { b[.social] = s }
            if g > 0 { b[.games] = g }
            if o > 0 { b[.other] = o }
            return b
        }
        day.pickupsHourly = [1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 0, 0]
        day.notificationsHourly = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0]
        day.mostUsed = [
            STAppValue(app: .telegram, value: 6 * 60 + 19),
            STAppValue(app: .meet, value: 4 * 60 + 1),
            STAppValue(app: .cod, value: 40),
            STAppValue(app: .safari, value: 35),
            STAppValue(app: .gta, value: 35),
            STAppValue(app: .settings, value: 5),
            STAppValue(app: .gbox, value: 4)
        ]
        day.firstUsedAfterPickup = [
            STAppValue(app: .telegram, value: 10),
            STAppValue(app: .meet, value: 6),
            STAppValue(app: .settings, value: 2),
            STAppValue(app: .cod, value: 1),
            STAppValue(app: .safari, value: 1)
        ]
        day.notificationsByApp = [
            STAppValue(app: .hokm, value: 2),
            STAppValue(app: .meet, value: 2),
            STAppValue(app: .telegram, value: 1),
            STAppValue(app: .whatsapp, value: 1)
        ]
        day.categoryTotals = [.social: 8 * 60 + 54, .games: 41, .other: 60]
        return day
    }
}

// MARK: - Formatting

extension ScreenTimeProvider {
    /// "Today, September 6" / "Yesterday, September 5" / "Friday, September 4"
    static func dayTitle(_ date: Date) -> String {
        let cal = Calendar.current
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM d"
        if cal.isDateInToday(date) { return "Today, \(f.string(from: date))" }
        if cal.isDateInYesterday(date) { return "Yesterday, \(f.string(from: date))" }
        let w = DateFormatter()
        w.locale = Locale(identifier: "en_US")
        w.dateFormat = "EEEE"
        return "\(w.string(from: date)), \(f.string(from: date))"
    }

    /// "Updated today at 18:23"
    static var updatedLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "HH:mm"
        return "Updated today at \(f.string(from: .now))"
    }

    /// Weekday name, e.g. "Friday".
    static func weekdayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE"
        return f.string(from: date)
    }
}
