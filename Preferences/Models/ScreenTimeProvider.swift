import SwiftUI
import Charts
import Observation

enum ScreenTimeCategory: String, CaseIterable, Codable, Plottable {
    case social = "Social"
    case entertainment = "Entertainment"
    case productivity = "Productivity & Finance"
    case creativity = "Creativity"
    case games = "Games"
    case information = "Information & Reading"
    case other = "Other"

    var color: Color {
        switch self {
        case .social: return .blue
        case .entertainment: return .teal
        case .productivity: return Color(red: 0.42, green: 0.45, blue: 0.68)
        case .creativity: return .orange
        case .games: return .purple
        case .information: return .mint
        case .other: return .gray
        }
    }
    var weight: Double {
        switch self {
        case .social: return 1.0
        case .entertainment: return 0.8
        case .productivity: return 0.6
        case .creativity: return 0.3
        case .games: return 0.4
        case .information: return 0.4
        case .other: return 0.3
        }
    }
}

struct AppUsage: Identifiable {
    var id: String { app.bundleID }
    let app: MockApp
    let minutes: Int
}

struct ScreenTimeDay: Identifiable {
    var id: Date { date }
    let date: Date
    let hourly: [[ScreenTimeCategory: Int]]   // 24 buckets
    let pickups: Int
    let notifications: Int
    let mostUsed: [AppUsage]

    var byCategory: [ScreenTimeCategory: Int] {
        hourly.reduce(into: [:]) { acc, b in for (k, v) in b { acc[k, default: 0] += v } }
    }
    var total: Int { byCategory.values.reduce(0, +) }
    var topCategories: [ScreenTimeCategory] {
        byCategory.sorted { $0.value > $1.value }.prefix(3).map(\.key)
    }
}

@MainActor
@Observable
final class ScreenTimeProvider {
    static let shared = ScreenTimeProvider()

    let week: [ScreenTimeDay]
    let lastWeekAverage = 231

    var today: ScreenTimeDay { week.last! }
    var dailyAverage: Int { week.map(\.total).reduce(0, +) / max(1, week.count) }
    var deltaPercent: Int { Int((Double(dailyAverage - lastWeekAverage) / Double(lastWeekAverage)) * 100) }
    var weekTopCategories: [ScreenTimeCategory] {
        var totals: [ScreenTimeCategory: Int] = [:]
        for d in week { for (k, v) in d.byCategory { totals[k, default: 0] += v } }
        return totals.sorted { $0.value > $1.value }.prefix(3).map(\.key)
    }
    func day(for date: Date?) -> ScreenTimeDay? {
        guard let date else { return nil }
        return week.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    init() {
        var rng = SeededGenerator(seed: 2026)
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        week = (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            var hourly: [[ScreenTimeCategory: Int]] = []
            for h in 0..<24 {
                var bucket: [ScreenTimeCategory: Int] = [:]
                let active: Double = (h >= 7 && h <= 23) ? 1 : 0.05
                for cat in ScreenTimeCategory.allCases {
                    let m = Int(Double.random(in: 0...(cat.weight * 8 * active), using: &rng))
                    if m > 0 { bucket[cat] = m }
                }
                hourly.append(bucket)
            }
            let apps = MockAppCatalog.all.shuffled(using: &rng).prefix(6)
                .map { AppUsage(app: $0, minutes: Int.random(in: 8...80, using: &rng)) }
                .sorted { $0.minutes > $1.minutes }
            return ScreenTimeDay(date: date, hourly: hourly,
                                 pickups: Int.random(in: 40...120, using: &rng),
                                 notifications: Int.random(in: 60...220, using: &rng),
                                 mostUsed: apps)
        }
    }
}
