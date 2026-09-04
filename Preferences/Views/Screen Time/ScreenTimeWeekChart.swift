import SwiftUI
import Charts

struct ScreenTimeWeekChart: View {
    let days: [ScreenTimeDay]
    let average: Int
    @Binding var selectedDay: Date?

    private func isSelected(_ day: ScreenTimeDay) -> Bool {
        guard let selectedDay else { return true }
        return Calendar.current.isDate(selectedDay, inSameDayAs: day.date)
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                ForEach(ScreenTimeCategory.allCases, id: \.self) { cat in
                    BarMark(x: .value("Day", day.date, unit: .day), y: .value("Minutes", day.byCategory[cat] ?? 0))
                        .foregroundStyle(by: .value("Category", cat))
                        .opacity(isSelected(day) ? 1 : 0.35)
                }
            }
            RuleMark(y: .value("avg", average))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                .foregroundStyle(.secondary)
                .annotation(position: .top, alignment: .trailing) { Text("avg").font(.caption2).foregroundStyle(.secondary) }
        }
        .chartForegroundStyleScale(domain: ScreenTimeCategory.allCases, range: ScreenTimeCategory.allCases.map(\.color))
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true) }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 120, 240, 360]) { v in
                AxisGridLine()
                AxisValueLabel { Text(minutesLabel(v.as(Int.self) ?? 0)) }
            }
        }
        .chartXSelection(value: $selectedDay)
        .frame(height: 150)
    }
}

struct ScreenTimeDayChart: View {
    let day: ScreenTimeDay
    var body: some View {
        Chart {
            ForEach(0..<24, id: \.self) { h in
                ForEach(ScreenTimeCategory.allCases, id: \.self) { cat in
                    BarMark(x: .value("Hour", h), y: .value("Minutes", day.hourly[h][cat] ?? 0))
                        .foregroundStyle(by: .value("Category", cat))
                }
            }
        }
        .chartForegroundStyleScale(domain: ScreenTimeCategory.allCases, range: ScreenTimeCategory.allCases.map(\.color))
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18]) { v in
                AxisValueLabel { Text(["12 AM", "6 AM", "12 PM", "6 PM"][(v.as(Int.self) ?? 0) / 6]) }
            }
        }
        .chartYAxis { AxisMarks(position: .trailing, values: [0, 30, 60]) { v in AxisGridLine(); AxisValueLabel { Text(minutesLabel(v.as(Int.self) ?? 0)) } } }
        .frame(height: 150)
    }
}
