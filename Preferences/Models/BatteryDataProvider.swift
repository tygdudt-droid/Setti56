import SwiftUI
import Observation

/// One column of the Daily Usage chart (last 8 days).
struct BatteryDay: Identifiable {
    let date: Date
    /// Total battery used that day; can exceed 100%.
    let allDay: Int
    /// Portion used by the current time of day (bottom, darker segment).
    let dailyByNow: Int
    var id: Date { date }
}

/// Battery level for one hour of the current day.
struct BatteryHour: Identifiable {
    enum State { case normal, charging, lowPower, none }
    let hour: Int
    let level: Int              // 0...100
    let state: State
    var id: Int { hour }
}

/// Charging window drawn as a rounded green band above the hourly bars.
struct ChargingSession: Identifiable {
    let start: Int              // first hour, inclusive
    let end: Int                // last hour, inclusive
    var id: Int { start }
}

/// A row in "Battery Usage by App" / "Other Battery Usage".
struct BatteryAppUsage: Identifiable {
    let id: String
    let name: String
    let icon: StorageIcon
    /// Single-line note ("On screen for 1h 13m longer", "Higher usage than usual").
    var note: String? = nil
    /// Two-line detail ("On screen: 6h 49m" / "Background: 4h 2m").
    var onScreen: Int? = nil
    var background: Int? = nil
    let percent: Int
    var warning: Bool = false

    /// "1h 13m" style label for a minute count.
    static func hm(_ m: Int) -> String { minutesLabel(m) }
}

/// Fixed mock battery data matching iPadOS 26.
@MainActor
@Observable
final class BatteryDataProvider {
    static let shared = BatteryDataProvider()

    // MARK: Level card
    let currentLevel = 38
    let lastChargedTo = 80
    let lastChargedAgo = "1h ago"

    // MARK: Daily Usage
    let averagePercent = 79
    let todayPercent = 134
    let days: [BatteryDay]

    // MARK: Today's hourly detail
    let hours: [BatteryHour]
    let chargingSessions: [ChargingSession] = [
        ChargingSession(start: 1, end: 4),
        ChargingSession(start: 13, end: 15),
        ChargingSession(start: 16, end: 17)
    ]
    let screenOnMinutes = 14 * 60 + 33      // 14h 33m
    let screenOffMinutes = 5 * 60 + 43      // 5h 43m

    // MARK: Health
    let healthStatus = "Normal"
    let maximumCapacity = 90
    let cycleCount = 434
    let manufactureDate = "March 2025"
    let firstUse = "July 2025"

    // MARK: App usage
    /// Rows shown on the Battery page (first three) and at the top of
    /// Battery Usage.
    let appUsage: [BatteryAppUsage] = [
        BatteryAppUsage(id: "telegram", name: "Telegram",
                        icon: .app(bundleID: "ph.telegra.Telegraph", symbol: "paperplane.fill", tint: "2AABEE"),
                        note: "On screen for 1h 13m longer", percent: 83, warning: true),
        BatteryAppUsage(id: "cod", name: "Call of Duty",
                        icon: .app(bundleID: "com.activision.callofduty.shooter", symbol: "scope", tint: "1C1C1E"),
                        note: "On screen for 43m longer", percent: 39, warning: true),
        BatteryAppUsage(id: "meet", name: "Meet",
                        icon: .app(bundleID: nil, symbol: "video.fill", tint: "F4B400"),
                        onScreen: 6 * 60 + 49, background: 4 * 60 + 2, percent: 3),
        BatteryAppUsage(id: "settings", name: "Settings",
                        icon: .app(bundleID: "com.apple.Preferences", symbol: "gearshape.fill", tint: "8E8E93"),
                        note: "Higher usage than usual", percent: 2, warning: true),
        BatteryAppUsage(id: "deleted", name: "Recently Deleted Apps",
                        icon: .app(bundleID: nil, symbol: "questionmark.app.dashed", tint: "8E8E93"),
                        onScreen: 29, background: 1, percent: 2, warning: true),
        BatteryAppUsage(id: "gbox", name: "GBox",
                        icon: .app(bundleID: nil, symbol: "shippingbox.fill", tint: "34C759"),
                        onScreen: 3, percent: 1, warning: true),
        BatteryAppUsage(id: "settings2", name: "Settings",
                        icon: .app(bundleID: nil, symbol: "gearshape.fill", tint: "8E8E93"),
                        onScreen: 14, percent: 1)
    ]

    let otherUsage: [BatteryAppUsage] = [
        BatteryAppUsage(id: "usbc", name: "USB-C Accessories",
                        icon: .app(bundleID: nil, symbol: "cable.connector", tint: "8E8E93"),
                        background: 56, percent: 1),
        BatteryAppUsage(id: "homelock", name: "Home & Lock Screen",
                        icon: .app(bundleID: nil, symbol: "apps.ipad", tint: "0A84FF"),
                        onScreen: 18, percent: 1)
    ]

    /// The three rows shown on the Battery page itself.
    var summaryUsage: [BatteryAppUsage] { Array(appUsage.prefix(2)) + [appUsage[3]] }

    /// "18:24" — the moment the report was generated.
    static var nowLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "HH:mm"
        return f.string(from: .now)
    }

    var usageSentence: String {
        "You’re using more battery today than you usually do by \(BatteryDataProvider.nowLabel)."
    }

    init() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        // All-day totals and the portion consumed by this time of day.
        let allDay = [128, 111, 146, 124, 134, 113, 134, 134]
        let byNow = [73, 49, 76, 60, 70, 62, 70, 134]
        days = (0..<8).map { i in
            let date = cal.date(byAdding: .day, value: -(7 - i), to: today) ?? today
            return BatteryDay(date: date, allDay: allDay[i], dailyByNow: byNow[i])
        }

        // Level per hour with its state; hours after "now" have no data.
        let levels = [62, 44, 26, 63, 82, 82, 84, 81, 80, 77, 73, 66,
                      53, 32, 29, 63, 82, 85, 68, 45, -1, -1, -1, -1]
        let charging: Set<Int> = [1, 2, 3, 4, 13, 14, 15, 16, 17]
        hours = (0..<24).map { h in
            let level = levels[h]
            if level < 0 { return BatteryHour(hour: h, level: 0, state: .none) }
            if charging.contains(h) { return BatteryHour(hour: h, level: level, state: .charging) }
            if h == 19 { return BatteryHour(hour: h, level: level, state: .lowPower) }
            return BatteryHour(hour: h, level: level, state: .normal)
        }
    }
}

/// Colors shared by the battery charts.
enum BatteryPalette {
    static let today = Color(red: 1.0, green: 0.62, blue: 0.04)         // orange
    static let allDayBar = Color(white: 0.29)
    static let dailyBar = Color(white: 0.21)
    static let charging = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let chargingBand = Color(red: 0.11, green: 0.44, blue: 0.20)
    static let lowPower = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let level = Color(white: 0.33)
    static let grid = Color(white: 0.24)
}
