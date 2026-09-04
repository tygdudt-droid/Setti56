import SwiftUI

struct ScreenTimeActivityView: View {
    let provider: ScreenTimeProvider
    @State private var mode = 1          // 0 Day, 1 Week
    @State private var selectedDay: Date?

    private var day: ScreenTimeDay { provider.day(for: selectedDay) ?? provider.today }
    private var mostUsed: [AppUsage] {
        if mode == 0 { return day.mostUsed }
        var totals: [String: (MockApp, Int)] = [:]
        for d in provider.week { for u in d.mostUsed { totals[u.app.bundleID, default: (u.app, 0)].1 += u.minutes } }
        return totals.values.map { AppUsage(app: $0.0, minutes: $0.1) }.sorted { $0.minutes > $1.minutes }
    }

    var body: some View {
        List {
            Section {
                Picker("", selection: $mode) { Text("Day").tag(0); Text("Week").tag(1) }
                    .pickerStyle(.segmented).listRowSeparator(.hidden)
                VStack(alignment: .leading, spacing: 8) {
                    Text(mode == 0 ? "SCREEN TIME" : "DAILY AVERAGE").font(.caption).foregroundStyle(.secondary)
                    HStack {
                        Text(minutesLabel(mode == 0 ? day.total : provider.dailyAverage)).font(.title.bold())
                        if mode == 1 { DeltaPill(percent: provider.deltaPercent) }
                    }
                    if mode == 0 { ScreenTimeDayChart(day: day) }
                    else { ScreenTimeWeekChart(days: provider.week, average: provider.dailyAverage, selectedDay: $selectedDay) }
                    LegendRow(categories: mode == 0 ? day.topCategories : provider.weekTopCategories)
                }
                .listRowSeparator(.hidden)
            }

            Section("Most Used") {
                let maxM = mostUsed.first?.minutes ?? 1
                ForEach(mostUsed) { u in
                    HStack(spacing: 12) {
                        AppIconView(app: u.app, side: 32)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack { Text(u.app.name); Spacer(); Text(minutesLabel(u.minutes)).foregroundStyle(.secondary) }
                            GeometryReader { g in
                                Capsule().fill(u.app.category.screenTimeCategory.color)
                                    .frame(width: g.size.width * CGFloat(u.minutes) / CGFloat(maxM))
                            }.frame(height: 4)
                        }
                    }
                }
            }
            Section("Pickups") {
                LabeledContent(mode == 0 ? "Total Pickups" : "Average Pickups", value: "\(mode == 0 ? day.pickups : provider.week.map(\.pickups).reduce(0, +) / 7)")
                LabeledContent("First Pickup", value: "7:41 AM")
            }
            Section("Notifications") {
                LabeledContent(mode == 0 ? "Total" : "Daily Average", value: "\(mode == 0 ? day.notifications : provider.week.map(\.notifications).reduce(0, +) / 7)")
            }
        }
        .navigationTitle(MockDevice.current.deviceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension AppLibraryCategory {
    var screenTimeCategory: ScreenTimeCategory {
        switch self {
        case .social: return .social
        case .entertainment: return .entertainment
        case .creativity: return .creativity
        case .productivity, .utilities: return .productivity
        case .games: return .games
        case .information: return .information
        default: return .other
        }
    }
}
