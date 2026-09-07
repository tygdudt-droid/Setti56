import SwiftUI

/// Daily Usage chart: one two-tone gray bar per day. The selected day is
/// drawn in the highlight color (orange when the day used more battery than
/// usual, blue otherwise) together with its label, rule and callout.
struct BatteryDailyUsageChart: View {
    let days: [BatteryDay]
    let average: Int
    /// Full report style: percent axis labels, date sub-labels and callout.
    var detailed = false
    /// Index of the highlighted day; tapping a column changes it.
    @Binding var selection: Int
    /// Color of the selected day.
    var highlight: Color = BatteryPalette.high
    var plotHeight: CGFloat = 150
    var maxValue: Int = 150

    private var lastIndex: Int { max(0, days.count - 1) }
    private var selected: Int { min(max(selection, 0), lastIndex) }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            GeometryReader { geo in
                let width = geo.size.width
                let colWidth = width / CGFloat(max(1, days.count))
                let barWidth = min(22, colWidth * 0.26)
                ZStack(alignment: .topLeading) {
                    // Grid
                    ForEach([maxValue, maxValue / 2, 0], id: \.self) { value in
                        Rectangle()
                            .fill(BatteryPalette.grid)
                            .frame(height: 0.5)
                            .offset(y: y(for: Double(value)))
                    }
                    // Average line (compact card only — the report uses the axis)
                    if !detailed {
                        Rectangle()
                            .fill(Color(white: 0.42))
                            .frame(height: 0.5)
                            .offset(y: y(for: Double(average)))
                    }
                    // Bars: identical grays for every day, highlight for the
                    // selected one. Color never depends on the value itself.
                    ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                        if day.allDay > 0 {
                            let isSelected = i == selected
                            let x = CGFloat(i) * colWidth + (colWidth - barWidth) / 2
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(isSelected ? highlight : BatteryPalette.allDayBar)
                                    .frame(height: height(for: Double(day.allDay - day.byEndOfDay)))
                                Rectangle()
                                    .fill(isSelected ? highlight : BatteryPalette.dailyBar)
                                    .frame(height: height(for: Double(day.byEndOfDay)))
                            }
                            .frame(width: barWidth, height: plotHeight, alignment: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                            .offset(x: x)
                        }
                    }
                    // Callout: rule through the column with the value to its left.
                    if detailed {
                        let day = days[selected]
                        let x = CGFloat(selected) * colWidth + colWidth / 2
                        Rectangle()
                            .fill(highlight)
                            .frame(width: 2, height: plotHeight + 70)
                            .offset(x: x - 1, y: -70)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(day.allDay)%")
                                .font(.system(size: 30, weight: .regular))
                                .foregroundStyle(highlight)
                            Text(Self.calloutDate(day.date))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 200, alignment: .trailing)
                        .offset(x: max(-8, x - 212), y: -78)
                    }
                    // X labels, centered under each column
                    ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                        VStack(spacing: 2) {
                            Text(Self.weekdayInitial(day.date))
                            if detailed, let sub = dateSubLabel(at: i) {
                                Text(sub)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(i == selected ? highlight : .secondary)
                        .frame(width: colWidth)
                        .offset(x: CGFloat(i) * colWidth, y: plotHeight + 6)
                    }
                    // Tap targets covering each whole column and its label
                    HStack(spacing: 0) {
                        ForEach(Array(days.enumerated()), id: \.offset) { i, _ in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) { selection = i }
                                }
                        }
                    }
                    .frame(width: width, height: plotHeight + (detailed ? 44 : 26))
                }
            }
            .frame(height: plotHeight + (detailed ? 46 : 28))

            // Right-hand labels
            ZStack(alignment: .topLeading) {
                if detailed {
                    ForEach([maxValue, maxValue / 2, 0], id: \.self) { value in
                        Text("\(value)%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .offset(y: y(for: Double(value)) - 9)
                    }
                } else {
                    Text("Average")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .offset(y: y(for: Double(average)) - 9)
                }
            }
            .frame(width: detailed ? 52 : 74,
                   height: plotHeight + (detailed ? 46 : 28),
                   alignment: .topLeading)
        }
    }

    private func height(for value: Double) -> CGFloat {
        plotHeight * CGFloat(min(max(value, 0), Double(maxValue)) / Double(maxValue))
    }
    private func y(for value: Double) -> CGFloat { plotHeight - height(for: value) }

    /// Date shown under the first bar and under the first bar of a new month.
    private func dateSubLabel(at index: Int) -> String? {
        let cal = Calendar.current
        let date = days[index].date
        if index == 0 || cal.component(.month, from: days[index - 1].date) != cal.component(.month, from: date) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "M/d"
            return f.string(from: date)
        }
        return nil
    }

    static func weekdayInitial(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEEE"
        return f.string(from: date)
    }

    static func calloutDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }
}

/// "● All Day   ● Daily by 01:24" (card) or "● All Day   ● Usage by End of
/// Day" (full report).
struct BatteryUsageLegend: View {
    var detailed = false

    var body: some View {
        HStack(spacing: 18) {
            item(BatteryPalette.allDayBar, "All Day")
            item(BatteryPalette.dailyBar, detailed ? "Usage by End of Day" : "Daily by \(BatteryDataProvider.nowLabel)")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private func item(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(text)
        }
    }
}

/// Hourly battery level for one day, with green charging bands (⚡, or ⏸
/// when charging was held back) and a yellow bar for Low Power Mode.
struct BatteryHourlyChart: View {
    let hours: [BatteryHour]
    let sessions: [ChargingSession]
    var plotHeight: CGFloat = 150

    private let bandHeight: CGFloat = 12

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            GeometryReader { geo in
                let width = geo.size.width
                let colWidth = width / 24
                let barWidth = colWidth * 0.66
                ZStack(alignment: .topLeading) {
                    ForEach([100, 50, 0], id: \.self) { value in
                        Rectangle()
                            .fill(BatteryPalette.grid)
                            .frame(height: 0.5)
                            .offset(y: y(for: Double(value)))
                    }
                    ForEach(hours) { hour in
                        if hour.state != .none {
                            let x = CGFloat(hour.hour) * colWidth + (colWidth - barWidth) / 2
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(color(for: hour.state))
                                .frame(width: barWidth, height: height(for: Double(hour.level)))
                                .offset(x: x, y: y(for: Double(hour.level)))
                        }
                    }
                    ForEach(sessions) { session in
                        let x = CGFloat(session.start) * colWidth + colWidth * 0.1
                        let w = CGFloat(session.end - session.start + 1) * colWidth - colWidth * 0.2
                        ZStack {
                            RoundedRectangle(cornerRadius: bandHeight / 2, style: .continuous)
                                .fill(session.paused ? Color(white: 0.30) : BatteryPalette.chargingBand)
                            Image(systemName: session.paused ? "pause.fill" : "bolt.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(session.paused ? Color.white : BatteryPalette.charging)
                        }
                        .frame(width: max(bandHeight, w), height: bandHeight)
                        .offset(x: x, y: -bandHeight / 2)
                    }
                    ForEach([0, 6, 12, 18], id: \.self) { h in
                        Text(String(format: "%02d", h))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .offset(x: CGFloat(h) * colWidth + 4, y: plotHeight + 6)
                    }
                }
            }
            .frame(height: plotHeight + 28)

            ZStack(alignment: .topLeading) {
                ForEach([100, 50, 0], id: \.self) { value in
                    Text("\(value)%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .offset(y: y(for: Double(value)) - 9)
                }
            }
            .frame(width: 52, height: plotHeight + 28, alignment: .topLeading)
        }
        .padding(.top, bandHeight)
    }

    private func color(for state: BatteryHour.State) -> Color {
        switch state {
        case .charging: return BatteryPalette.charging
        case .lowPower: return BatteryPalette.lowPower
        default: return BatteryPalette.level
        }
    }

    private func height(for value: Double) -> CGFloat {
        plotHeight * CGFloat(min(max(value, 0), 100) / 100)
    }
    private func y(for value: Double) -> CGFloat { plotHeight - height(for: value) }
}

/// One row of "Battery Usage by App" / "Other Battery Usage".
struct BatteryAppRow: View {
    let usage: BatteryAppUsage

    var body: some View {
        HStack(spacing: 14) {
            StorageIconView(icon: usage.icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(usage.name)
                if let note = usage.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    if let onScreen = usage.onScreen {
                        Text("On screen: \(minutesLabel(onScreen))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if let background = usage.background {
                        Text("Background: \(minutesLabel(background))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer(minLength: 8)
            HStack(spacing: 5) {
                if usage.warning {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(BatteryPalette.high)
                }
                Text("\(usage.percent)%")
                    .foregroundStyle(usage.warning ? BatteryPalette.high : .secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
