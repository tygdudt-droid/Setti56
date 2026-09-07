import SwiftUI

/// Top card of Settings > Battery: the real charge level, ⓘ button, the
/// charging line and the level track.
///
/// Three states, like iPadOS: plugged in ("⚡ Charging" with a green track
/// and the 100% target on the right), full ("⚡ Fully Charged", track filled
/// green) and unplugged ("Last Charged to X%: 1h ago", gray track).
struct BatteryHeaderCard: View {
    let data: BatteryDataProvider
    @State private var liveLevel: Int? = DeviceBattery.level
    @State private var charging = DeviceBattery.isCharging
    @State private var full = DeviceBattery.isFull
    @State private var showingInfo = false

    /// Real level on device, mock value in the Simulator.
    private var level: Int { liveLevel ?? data.mockLevel }
    private var pluggedIn: Bool { charging || full }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(level)")
                        .font(.system(size: 34, weight: .bold))
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button { showingInfo = true } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                if pluggedIn {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline)
                        Text(full ? "Fully Charged" : "Charging")
                    }
                    .foregroundStyle(BatteryPalette.charging)
                } else {
                    Text("Last Charged to \(DeviceBattery.lastChargedTo)%: \(DeviceBattery.lastChargedAgo)")
                }
                Spacer()
                if charging {
                    Text("100%").foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)

            levelTrack
                .padding(.top, 12)
        }
        .padding(.vertical, 4)
        .onAppear { refresh() }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)) { _ in
            refresh()
        }
        .alert("Battery Level", isPresented: $showingInfo) {
            Button("OK") {}
        } message: {
            Text("The bar shows the current charge level of this \(MockDevice.current.deviceTypeName).")
        }
    }

    private func refresh() {
        DeviceBattery.recordIfCharging()
        withAnimation(.easeInOut(duration: 0.25)) {
            liveLevel = DeviceBattery.level
            charging = DeviceBattery.isCharging
            full = DeviceBattery.isFull
        }
    }

    private var levelTrack: some View {
        GeometryReader { geo in
            let filled = geo.size.width * CGFloat(level) / 100
            ZStack(alignment: .leading) {
                Capsule().fill(Color(white: 0.34))
                Capsule()
                    .fill(pluggedIn ? BatteryPalette.charging : Color(white: 0.55))
                    .frame(width: filled)
            }
        }
        .frame(height: 7)
    }
}

/// The "Daily Usage" card body shared by Battery and Battery Usage: the
/// sentence, Average / selected-day figures, chart and legend.
struct BatteryDailyUsageCard: View {
    let data: BatteryDataProvider
    /// Full report style (percent axis labels, date sub-labels, callout).
    var detailed = false
    @Binding var selection: Int

    private var index: Int { min(max(selection, 0), data.days.count - 1) }
    private var day: BatteryDay { data.days[index] }
    private var isToday: Bool { index == data.todayIndex }
    private var highlight: Color { data.highlightColor(for: day) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(data.sentence(for: day, index: index))
                .padding(.bottom, detailed ? 0 : 14)

            if !detailed {
                Divider()
                    .padding(.bottom, 14)
                HStack(alignment: .top, spacing: 0) {
                    figure("Average", data.averagePercent, color: .primary, labelColor: .secondary)
                        .frame(width: 128, alignment: .leading)
                    figure(isToday ? "Today" : Self.shortDate(day.date), day.allDay,
                           color: highlight, labelColor: highlight)
                    Spacer()
                }
                .padding(.bottom, 10)
            }

            BatteryDailyUsageChart(days: data.days,
                                   average: data.averagePercent,
                                   detailed: detailed,
                                   selection: $selection,
                                   highlight: highlight)
                .padding(.top, detailed ? 78 : 0)

            BatteryUsageLegend(detailed: detailed)
                .padding(.top, 12)
        }
    }

    private func figure(_ title: String, _ value: Int, color: Color, labelColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(labelColor)
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(value)")
                    .font(.system(size: 30, weight: .regular))
                    .contentTransition(.numericText())
                Text("%").font(.system(size: 18, weight: .regular))
            }
            .foregroundStyle(color)
        }
    }

    static func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
