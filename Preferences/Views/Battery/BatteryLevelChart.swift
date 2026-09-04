import SwiftUI
import Charts

struct BatteryLevelChart: View {
    let samples: [BatterySample]
    @Binding var selection: Date?

    var body: some View {
        Chart {
            ForEach(samples) { s in
                if s.charging {
                    RectangleMark(xStart: .value("s", s.date), xEnd: .value("e", s.date.addingTimeInterval(900)),
                                  yStart: .value("0", 0), yEnd: .value("100", 100))
                        .foregroundStyle(Color.green.opacity(0.12))
                }
                if s.lowPower {
                    RectangleMark(xStart: .value("s", s.date), xEnd: .value("e", s.date.addingTimeInterval(900)),
                                  yStart: .value("0", 0), yEnd: .value("100", 100))
                        .foregroundStyle(Color.yellow.opacity(0.18))
                }
                AreaMark(x: .value("Time", s.date), y: .value("Level", s.level * 100))
                    .foregroundStyle(Color.green.opacity(s.charging ? 0.25 : 0.45))
                    .interpolationMethod(.stepEnd)
                LineMark(x: .value("Time", s.date), y: .value("Level", s.level * 100))
                    .foregroundStyle(Color.green)
                    .interpolationMethod(.stepEnd)
            }
            if let selection, let s = samples.nearest(to: selection) {
                RuleMark(x: .value("Selected", s.date)).foregroundStyle(.secondary)
                    .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.date.formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
                            Text("\(Int(s.level * 100))%").font(.headline)
                            if s.charging { Text("Charging").font(.caption2).foregroundStyle(.green) }
                        }
                        .padding(8)
                        .glassCard(cornerRadius: 10)
                    }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100]) { v in
                AxisGridLine()
                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)%") }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .chartXSelection(value: $selection)
        .frame(height: 170)
    }
}

struct BatteryTenDayChart: View {
    let days: [BatteryDay]
    @Binding var selection: Date?

    var body: some View {
        Chart {
            ForEach(days) { d in
                BarMark(x: .value("Day", d.date, unit: .day), y: .value("Used", d.percentUsed))
                    .foregroundStyle(Color.green)
                    .opacity(selection == nil || Calendar.current.isDate(selection ?? .distantPast, inSameDayAs: d.date) ? 1 : 0.35)
                    .cornerRadius(3)
            }
            if let sel = selection, let d = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: sel) }) {
                RuleMark(x: .value("Selected", d.date, unit: .day)).foregroundStyle(.clear)
                    .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(d.date.formatted(.dateTime.weekday(.wide))).font(.caption2).foregroundStyle(.secondary)
                            Text("\(d.percentUsed)%").font(.headline)
                        }
                        .padding(8).glassCard(cornerRadius: 10)
                    }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100, 150]) { v in
                AxisGridLine()
                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)%") }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true) }
        }
        .chartXSelection(value: $selection)
        .frame(height: 170)
    }
}
