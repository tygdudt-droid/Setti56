import SwiftUI

/// Top card of Settings > Battery: big percentage (read from the real
/// device when available), ⓘ button, last-charge line and the level track.
struct BatteryHeaderCard: View {
    let data: BatteryDataProvider
    @State private var liveLevel: Int? = DeviceBattery.level
    @State private var charging = DeviceBattery.isCharging
    @State private var showingInfo = false

    /// Real level on device, mock value in the Simulator.
    private var level: Int { liveLevel ?? data.currentLevel }

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
                    if charging {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline)
                            .foregroundStyle(BatteryPalette.charging)
                    }
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

            Text(DeviceBattery.chargeLine(fallbackTo: data.lastChargedTo, ago: data.lastChargedAgo))
                .padding(.top, 4)

            levelTrack
                .padding(.top, 14)
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
        withAnimation(.easeInOut(duration: 0.25)) {
            liveLevel = DeviceBattery.level
            charging = DeviceBattery.isCharging
        }
    }

    private var levelTrack: some View {
        GeometryReader { geo in
            let filled = geo.size.width * CGFloat(level) / 100
            HStack(spacing: 0) {
                Rectangle().fill(Color(white: 0.55)).frame(width: filled)
                Rectangle().fill(Color(white: 0.34))
            }
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
        .frame(height: 6)
    }
}

/// The "Daily Usage" card body shared by Battery and Battery Usage:
/// the sentence, Average / selected-day figures, chart and legend.
struct BatteryDailyUsageCard: View {
    let data: BatteryDataProvider
    /// Full report style (percent axis labels, date sub-labels, callout).
    var detailed = false
    @Binding var selection: Int

    private var selectedDay: BatteryDay { data.days[min(selection, data.days.count - 1)] }
    private var isToday: Bool { selection == data.days.count - 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(detailed ? String(data.usageSentence.dropLast()) : data.usageSentence)
                .padding(.bottom, detailed ? 0 : 14)

            if !detailed {
                Divider()
                    .padding(.bottom, 14)
                HStack(alignment: .top, spacing: 0) {
                    figure("Average", "\(data.averagePercent)", color: .primary, labelColor: .secondary)
                        .frame(width: 128, alignment: .leading)
                    figure(isToday ? "Today" : Self.shortDate(selectedDay.date),
                           "\(selectedDay.allDay)",
                           color: BatteryPalette.today, labelColor: BatteryPalette.today)
                    Spacer()
                }
                .padding(.bottom, 10)
            }

            BatteryDailyUsageChart(days: data.days,
                                   average: data.averagePercent,
                                   detailed: detailed,
                                   selection: $selection)
                .padding(.top, detailed ? 46 : 0)

            BatteryUsageLegend()
                .padding(.top, 12)
        }
    }

    private func figure(_ title: String, _ value: String, color: Color, labelColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(labelColor)
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value).font(.system(size: 30, weight: .regular))
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
