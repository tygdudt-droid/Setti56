import SwiftUI

/// Daily Usage chart: one two-tone gray bar per day, today's bar orange,
/// a thin "Average" line, weekday initials and (on the full report) date
/// sub-labels, right-hand percentage labels and the selected-day callout.
struct BatteryDailyUsageChart: View {
    let days: [BatteryDay]
    let average: Int
    /// Shows 150% / 75% / 0% labels, date sub-labels and the today callout.
    var detailed = false
    var plotHeight: CGFloat = 150
    var maxValue: Int = 150

    private let labelWidth: CGFloat = 52

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            GeometryReader { geo in
                let width = geo.size.width
                let colWidth = width / CGFloat(max(1, days.count))
                let barWidth = colWidth * 0.28
                ZStack(alignment: .topLeading) {
                    // Grid
                    ForEach([maxValue, maxValue / 2, 0], id: \.self) { value in
                        Rectangle()
                            .fill(BatteryPalette.grid)
                            .frame(height: 0.5)
                            .offset(y: y(for: Double(value)))
                    }
                    // Average line
                    Rectangle()
                        .fill(Color(white: 0.45))
                        .frame(height: 0.5)
                        .offset(y: y(for: Double(average)))
                    // Bars
                    ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                        let isToday = i == days.count - 1
                        let x = CGFloat(i) * colWidth + (colWidth - barWidth) / 2
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(isToday ? BatteryPalette.today : BatteryPalette.allDayBar)
                                .frame(height: height(for: Double(day.allDay - day.dailyByNow)))
                            Rectangle()
                                .fill(isToday ? BatteryPalette.today : BatteryPalette.dailyBar)
                                .frame(height: height(for: Double(day.dailyByNow)))
                        }
                        .frame(width: barWidth, height: plotHeight, alignment: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        .offset(x: x)
                    }
                    // Today callout (orange rule + value)
                    if detailed, let last = days.last {
                        let x = CGFloat(days.count - 1) * colWidth + colWidth / 2
                        Rectangle()
                            .fill(BatteryPalette.today)
                            .frame(width: 1.5, height: plotHeight)
                            .offset(x: x - 0.75)
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(last.allDay)%")
                                .font(.title2)
                                .foregroundStyle(BatteryPalette.today)
                            Text(Self.calloutDate(last.date))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 180, alignment: .trailing)
                        .offset(x: x - 190, y: -62)
                    }
                    // X labels
                    ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                        let isToday = i == days.count - 1
                        VStack(spacing: 2) {
                            Text(Self.weekdayInitial(day.date))
                            if detailed, let sub = dateSubLabel(at: i) {
                                Text(sub)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(isToday && detailed ? BatteryPalette.today : .secondary)
                        .frame(width: colWidth)
                        .offset(x: CGFloat(i) * colWidth, y: plotHeight + 6)
                    }
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
            .frame(width: detailed ? labelWidth : 74,
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

/// "● All Day   ● Daily by 18:24"
struct BatteryUsageLegend: View {
    var body: some View {
        HStack(spacing: 18) {
            item(BatteryPalette.allDayBar, "All Day")
            item(BatteryPalette.dailyBar, "Daily by \(BatteryDataProvider.nowLabel)")
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

/// Hourly battery level for today, with green charging bands (⚡) above the
/// bars and a yellow bar for Low Power Mode.
struct BatteryHourlyChart: View {
    let hours: [BatteryHour]
    let sessions: [ChargingSession]
    var plotHeight: CGFloat = 150

    private let labelWidth: CGFloat = 52
    private let bandHeight: CGFloat = 11

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            GeometryReader { geo in
                let width = geo.size.width
                let colWidth = width / 24
                let barWidth = colWidth * 0.62
                ZStack(alignment: .topLeading) {
                    // Grid
                    ForEach([100, 50, 0], id: \.self) { value in
                        Rectangle()
                            .fill(BatteryPalette.grid)
                            .frame(height: 0.5)
                            .offset(y: y(for: Double(value)))
                    }
                    // Bars
                    ForEach(hours) { hour in
                        if hour.state != .none {
                            let x = CGFloat(hour.hour) * colWidth + (colWidth - barWidth) / 2
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(color(for: hour.state))
                                .frame(width: barWidth, height: height(for: Double(hour.level)))
                                .offset(x: x, y: y(for: Double(hour.level)))
                        }
                    }
                    // Charging bands
                    ForEach(sessions) { session in
                        let x = CGFloat(session.start) * colWidth + colWidth * 0.12
                        let w = CGFloat(session.end - session.start + 1) * colWidth - colWidth * 0.24
                        ZStack {
                            RoundedRectangle(cornerRadius: bandHeight / 2, style: .continuous)
                                .fill(BatteryPalette.chargingBand)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(BatteryPalette.charging)
                        }
                        .frame(width: max(0, w), height: bandHeight)
                        .offset(x: x, y: -bandHeight / 2)
                    }
                    // X labels
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
            .frame(width: labelWidth, height: plotHeight + 28, alignment: .topLeading)
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
                        .foregroundStyle(BatteryPalette.today)
                }
                Text("\(usage.percent)%")
                    .foregroundStyle(usage.warning ? BatteryPalette.today : .secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
