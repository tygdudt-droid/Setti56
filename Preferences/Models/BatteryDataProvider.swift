import SwiftUI
import Observation

struct BatterySample: Identifiable, Codable {
    let id: UUID
    let date: Date
    let level: Double   // 0...1
    let charging: Bool
    let lowPower: Bool
    let screenOn: Bool
}

struct AppBatteryUsage: Identifiable {
    var id: String { app.bundleID }
    let app: MockApp
    let screenOnMinutes: Int
    let backgroundMinutes: Int
    var energyShare: Double
}

struct BatteryDay: Identifiable {
    var id: Date { date }
    let date: Date
    let percentUsed: Int
    let screenOnMinutes: Int
    let screenOffMinutes: Int
    let apps: [AppBatteryUsage]
}

@MainActor
@Observable
final class BatteryDataProvider {
    static let shared = BatteryDataProvider()

    let last24h: [BatterySample]
    let last10d: [BatteryDay]
    let todayApps: [AppBatteryUsage]
    let lastChargedTo = 100
    let lastChargedAt: Date
    let maximumCapacity = 96
    let cycleCount = 187

    var currentLevel: Int { Int((last24h.last?.level ?? 0.8) * 100) }
    var screenOnMinutesToday: Int { last24h.filter(\.screenOn).count * 15 / 2 }
    var screenOffMinutesToday: Int { last24h.filter { !$0.screenOn }.count * 15 / 2 }
    var todayUsagePercent: Int { 100 - currentLevel }
    var dailyAveragePercent: Int { last10d.dropLast().map(\.percentUsed).reduce(0, +) / max(1, last10d.count - 1) }

    init() {
        var rng = SeededGenerator(seed: 26)
        let now = Date.now
        let cal = Calendar.current
        let charged = cal.date(bySettingHour: 7, minute: 32, second: 0, of: now) ?? now
        lastChargedAt = charged > now ? charged.addingTimeInterval(-86_400) : charged

        var samples: [BatterySample] = []
        for i in 0..<96 {
            let t = now.addingTimeInterval(TimeInterval(-15 * 60 * (95 - i)))
            let hoursSinceCharge = t.timeIntervalSince(lastChargedAt) / 3600
            let charging = hoursSinceCharge < 0 && hoursSinceCharge > -2.5
            let level: Double
            if charging {
                level = min(1, 0.55 + (2.5 + hoursSinceCharge) * 0.18)
            } else if hoursSinceCharge < 0 {
                level = max(0.15, 0.95 - (-hoursSinceCharge - 2.5) * 0.04)
            } else {
                level = max(0.12, 1 - hoursSinceCharge * 0.045 + Double.random(in: -0.008...0.008, using: &rng))
            }
            let hour = cal.component(.hour, from: t)
            let screenOn = (hour >= 8 && hour <= 23) && Bool.random(using: &rng)
            samples.append(BatterySample(id: UUID(), date: t, level: level, charging: charging, lowPower: level < 0.2, screenOn: screenOn))
        }
        last24h = samples

        func makeApps(_ rng: inout SeededGenerator) -> [AppBatteryUsage] {
            var apps = MockAppCatalog.all.shuffled(using: &rng).prefix(8).map {
                AppBatteryUsage(app: $0,
                                screenOnMinutes: Int.random(in: 4...95, using: &rng),
                                backgroundMinutes: Int.random(in: 0...30, using: &rng),
                                energyShare: 0)
            }
            let total = Double(apps.map { $0.screenOnMinutes + $0.backgroundMinutes }.reduce(0, +))
            for i in apps.indices {
                apps[i].energyShare = Double(apps[i].screenOnMinutes + apps[i].backgroundMinutes) / max(1, total)
            }
            return apps.sorted { $0.energyShare > $1.energyShare }
        }

        var days: [BatteryDay] = []
        for d in (0..<10).reversed() {
            let date = cal.startOfDay(for: cal.date(byAdding: .day, value: -d, to: now) ?? now)
            days.append(BatteryDay(date: date,
                                   percentUsed: Int.random(in: 45...130, using: &rng),
                                   screenOnMinutes: Int.random(in: 120...420, using: &rng),
                                   screenOffMinutes: Int.random(in: 60...420, using: &rng),
                                   apps: makeApps(&rng)))
        }
        last10d = days
        todayApps = days.last?.apps ?? []
    }
}


extension Array where Element == BatterySample {
    func nearest(to date: Date) -> BatterySample? {
        self.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }
}
