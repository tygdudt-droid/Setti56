import SwiftUI
import Observation

/// Battery level for one hour of a day.
struct BatteryHour: Identifiable {
    enum State { case normal, charging, lowPower, none }
    let hour: Int
    let level: Int              // 0...100
    let state: State
    var id: Int { hour }
}

/// Charging window drawn as a rounded green band above the hourly bars.
/// `paused` renders the ⏸ badge iOS shows when charging was held back.
struct ChargingSession: Identifiable {
    let start: Int              // first hour, inclusive
    let end: Int                // last hour, inclusive
    var paused = false
    var id: Int { start * 2 + (paused ? 1 : 0) }
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
}

/// One column of the Daily Usage chart, with everything the report needs.
struct BatteryDay: Identifiable {
    let date: Date
    /// Total battery used that day; can exceed 100%.
    let allDay: Int
    /// Portion used by the current time of day (bottom, darker segment).
    let byEndOfDay: Int
    let hours: [BatteryHour]
    let sessions: [ChargingSession]
    let screenOn: Int
    let screenOff: Int
    let apps: [BatteryAppUsage]
    let other: [BatteryAppUsage]
    var id: Date { date }
}

/// Mock battery report: eight days ending today, each with its own hourly
/// levels, charging sessions and per-app usage.
@MainActor
@Observable
final class BatteryDataProvider {
    static let shared = BatteryDataProvider()

    let days: [BatteryDay]
    var today: BatteryDay { days[days.count - 1] }
    var todayIndex: Int { days.count - 1 }

    /// Average of the completed days (today is still in progress).
    let averagePercent: Int

    // MARK: Health
    let healthStatus = "Normal"
    let maximumCapacity = 90
    let cycleCount = 434
    let manufactureDate = "March 2025"
    let firstUse = "July 2025"

    /// Fallback level when the device reports none (Simulator).
    let mockLevel = 38

    /// "01:24" — the moment the report was generated.
    static var nowLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "HH:mm"
        return f.string(from: .now)
    }

    /// How a day compares with the average.
    enum Comparison { case more, similar, less
        var isHigh: Bool { self == .more }
    }

    func comparison(for day: BatteryDay) -> Comparison {
        let avg = Double(max(1, averagePercent))
        let ratio = Double(day.allDay) / avg
        if ratio > 1.35 { return .more }
        if ratio < 0.65 { return .less }
        return .similar
    }

    /// Highlight color: orange above the usual amount, blue otherwise.
    func highlightColor(for day: BatteryDay) -> Color {
        comparison(for: day).isHigh ? BatteryPalette.high : BatteryPalette.normal
    }

    /// The sentence at the top of the Daily Usage card.
    func sentence(for day: BatteryDay, index: Int) -> String {
        let isToday = index == todayIndex
        switch comparison(for: day) {
        case .more:
            return isToday
                ? "You’re using more battery today than you usually do by \(Self.nowLabel)."
                : "You used more battery on \(Self.weekdayName(day.date)) than you usually do."
        case .less:
            return isToday
                ? "You’re using less battery today than you usually do by \(Self.nowLabel)."
                : "You used less battery on \(Self.weekdayName(day.date)) than you usually do."
        case .similar:
            return isToday
                ? "You’re using a similar amount of battery today as you usually do by \(Self.nowLabel)."
                : "You used a similar amount of battery on \(Self.weekdayName(day.date)) as you usually do."
        }
    }

    static func weekdayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE"
        return f.string(from: date)
    }

    init() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let hourNow = cal.component(.hour, from: .now)
        // All-day totals for the eight columns; today is still in progress.
        let totals = [105, 150, 99, 96, 88, 118, 150, 11]
        var built: [BatteryDay] = []
        for i in 0..<8 {
            let date = cal.date(byAdding: .day, value: -(7 - i), to: today) ?? today
            let isToday = i == 7
            built.append(BatteryDataProvider.makeDay(
                date: date, seed: UInt64(4100 + i * 17),
                allDay: totals[i],
                isToday: isToday,
                lastHour: isToday ? hourNow : 23
            ))
        }
        days = built
        let completed = built.dropLast()
        averagePercent = completed.map(\.allDay).reduce(0, +) / max(1, completed.count)
    }

    // MARK: Day generation

    private static func makeDay(date: Date, seed: UInt64, allDay: Int, isToday: Bool, lastHour: Int) -> BatteryDay {
        var rng = SeededGenerator(seed: seed)

        // Charging windows: one overnight plus one or two during the day.
        var sessions: [ChargingSession] = []
        let nightStart = Int.random(in: 0...2, using: &rng)
        sessions.append(ChargingSession(start: nightStart, end: nightStart + Int.random(in: 2...3, using: &rng)))
        if Bool.random(using: &rng) {
            let s = Int.random(in: 11...14, using: &rng)
            sessions.append(ChargingSession(start: s, end: s + Int.random(in: 1...2, using: &rng)))
        }
        if Bool.random(using: &rng) {
            let s = Int.random(in: 16...19, using: &rng)
            sessions.append(ChargingSession(start: s, end: s + 1))
        }
        // Occasional held-back charging badge.
        if Bool.random(using: &rng), let first = sessions.first {
            sessions.append(ChargingSession(start: min(23, first.end + 1), end: min(23, first.end + 1), paused: true))
        }
        sessions = sessions.filter { $0.start <= lastHour }.map {
            ChargingSession(start: $0.start, end: min($0.end, lastHour), paused: $0.paused)
        }

        let chargingHours = Set(sessions.filter { !$0.paused }.flatMap { Array($0.start...$0.end) })
        let hasLowPower = Bool.random(using: &rng)
        let lowPowerCandidate = Int.random(in: 17...20, using: &rng)
        let lowPowerHour = hasLowPower ? lowPowerCandidate : -1

        // Walk the day: rise while charging, fall otherwise.
        var level = Double(Int.random(in: 45...80, using: &rng))
        var hours: [BatteryHour] = []
        for h in 0..<24 {
            guard h <= lastHour else {
                hours.append(BatteryHour(hour: h, level: 0, state: .none))
                continue
            }
            if chargingHours.contains(h) {
                level = min(100, level + Double.random(in: 12...26, using: &rng))
            } else {
                level = max(6, level - Double(allDay) / 24.0 * Double.random(in: 0.7...1.6, using: &rng))
            }
            let state: BatteryHour.State = chargingHours.contains(h)
                ? .charging
                : (h == lowPowerHour ? .lowPower : .normal)
            hours.append(BatteryHour(hour: h, level: Int(level.rounded()), state: state))
        }

        // Screen time for the day.
        let onMinutes = isToday
            ? Int.random(in: 30...240, using: &rng)
            : Int.random(in: 8 * 60...23 * 60, using: &rng)
        let offMinutes = max(20, (isToday ? (lastHour + 1) * 60 : 24 * 60) - onMinutes)

        // Each `&rng` use is hoisted: Swift forbids two exclusive accesses
        // to the same variable inside one call expression.
        let share = Double.random(in: 0.45...0.75, using: &rng)
        let byEnd = isToday ? allDay : Int(Double(allDay) * share)
        let apps = makeApps(&rng, allDay: allDay)
        let other = makeOther(&rng)

        return BatteryDay(date: date, allDay: allDay,
                          byEndOfDay: byEnd,
                          hours: hours, sessions: sessions,
                          screenOn: onMinutes, screenOff: offMinutes,
                          apps: apps,
                          other: other)
    }

    /// Pool of apps that can appear in a day's report.
    private static let pool: [(id: String, name: String, icon: StorageIcon)] = [
        ("telegram", "Telegram", .app(bundleID: "ph.telegra.Telegraph", symbol: "paperplane.fill", tint: "2AABEE")),
        ("cod", "Call of Duty", .app(bundleID: "com.activision.callofduty.shooter", symbol: "scope", tint: "1C1C1E")),
        ("meet", "Meet", .app(bundleID: nil, symbol: "video.fill", tint: "F4B400")),
        ("inshot", "InShot", .app(bundleID: nil, symbol: "camera.fill", tint: "FF2D55")),
        ("settings", "Settings", .app(bundleID: "com.apple.Preferences", symbol: "gearshape.fill", tint: "8E8E93")),
        ("deleted", "Recently Deleted Apps", .app(bundleID: nil, symbol: "questionmark.app.dashed", tint: "8E8E93")),
        ("gbox", "GBox", .app(bundleID: nil, symbol: "shippingbox.fill", tint: "34C759")),
        ("safari", "Safari", .app(bundleID: "com.apple.mobilesafari", symbol: "safari.fill", tint: "0A84FF"))
    ]

    private static func makeApps(_ rng: inout SeededGenerator, allDay: Int) -> [BatteryAppUsage] {
        var remaining = 100
        var result: [BatteryAppUsage] = []
        let count = Int.random(in: 5...7, using: &rng)
        let chosen = pool.shuffled(using: &rng).prefix(count)
        for (i, entry) in chosen.enumerated() {
            let isLast = i == chosen.count - 1
            let percent = isLast ? max(1, remaining) : max(1, Int(Double(remaining) * Double.random(in: 0.35...0.7, using: &rng)))
            remaining = max(1, remaining - percent)
            let onScreen = Int.random(in: 3...300, using: &rng)
            let hasBackground = Bool.random(using: &rng)
            let backgroundMinutes = Int.random(in: 1...240, using: &rng)
            let longerMinutes = Int.random(in: 20...120, using: &rng)
            let longer = percent > 35 && Bool.random(using: &rng)
            result.append(BatteryAppUsage(
                id: entry.id, name: entry.name, icon: entry.icon,
                note: longer ? "On screen for \(minutesLabel(longerMinutes)) longer" : nil,
                onScreen: longer ? nil : onScreen,
                background: longer ? nil : (hasBackground ? backgroundMinutes : nil),
                percent: percent,
                warning: percent >= 30
            ))
        }
        return result.sorted { $0.percent > $1.percent }
    }

    private static func makeOther(_ rng: inout SeededGenerator) -> [BatteryAppUsage] {
        let usbMinutes = Int.random(in: 10...90, using: &rng)
        let homeMinutes = Int.random(in: 5...40, using: &rng)
        return [
            BatteryAppUsage(id: "usbc", name: "USB-C Accessories",
                            icon: .app(bundleID: nil, symbol: "cable.connector", tint: "8E8E93"),
                            background: usbMinutes, percent: 1),
            BatteryAppUsage(id: "homelock", name: "Home & Lock Screen",
                            icon: .app(bundleID: nil, symbol: "apps.ipad", tint: "0A84FF"),
                            onScreen: homeMinutes, percent: 1)
        ]
    }
}

/// Reads the real charge level and charging state from the device.
///
/// `UIDevice` reports -1 when battery monitoring is unavailable (Simulator,
/// Previews), in which case the mock value is used instead.
enum DeviceBattery {
    static func startMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    /// Real charge level 0…100, or nil when the device does not report one.
    static var level: Int? {
        startMonitoring()
        let value = UIDevice.current.batteryLevel
        guard value >= 0 else { return nil }
        return Int((value * 100).rounded())
    }

    static var state: UIDevice.BatteryState {
        startMonitoring()
        return UIDevice.current.batteryState
    }

    static var isCharging: Bool { state == .charging }
    static var isFull: Bool { state == .full }
    static var isPluggedIn: Bool { isCharging || isFull }

    // MARK: Last charge

    private static let levelKey = "battery.lastChargedTo"
    private static let dateKey = "battery.lastChargedAt"

    /// Remembers the level while plugged in so "Last Charged to X%" is real.
    static func recordIfCharging() {
        guard isPluggedIn, let level else { return }
        let d = UserDefaults.standard
        d.set(level, forKey: levelKey)
        d.set(Date.now.timeIntervalSince1970, forKey: dateKey)
    }

    static var lastChargedTo: Int {
        let stored = UserDefaults.standard.integer(forKey: levelKey)
        return stored > 0 ? stored : (level ?? 80)
    }

    /// "now", "12m ago", "3h ago", "2d ago"
    static var lastChargedAgo: String {
        let stamp = UserDefaults.standard.double(forKey: dateKey)
        guard stamp > 0 else { return "now" }
        let seconds = Date.now.timeIntervalSince1970 - stamp
        if seconds < 120 { return "now" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86_400 { return "\(Int(seconds / 3600))h ago" }
        return "\(Int(seconds / 86_400))d ago"
    }
}

/// Colors shared by the battery charts.
enum BatteryPalette {
    /// Above the usual amount.
    static let high = Color(red: 1.0, green: 0.62, blue: 0.04)
    /// At or below the usual amount.
    static let normal = Color(red: 0.04, green: 0.52, blue: 1.0)
    static let allDayBar = Color(white: 0.42)
    static let dailyBar = Color(white: 0.26)
    static let charging = Color(red: 0.22, green: 0.85, blue: 0.38)
    static let chargingBand = Color(red: 0.11, green: 0.44, blue: 0.20)
    static let lowPower = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let level = Color(white: 0.33)
    static let grid = Color(white: 0.24)
}
