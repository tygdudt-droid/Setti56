import SwiftUI

struct BatteryHeaderCard: View {
    let data: BatteryDataProvider

    private var sentence: String {
        let diff = data.todayUsagePercent - data.dailyAveragePercent
        if abs(diff) <= 8 { return "Battery usage is similar to your typical usage." }
        return diff > 0 ? "Battery usage is higher than your typical usage." : "Battery usage is lower than your typical usage."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(data.currentLevel)%").font(.system(size: 44, weight: .semibold, design: .rounded))
                Image(systemName: "battery.100percent").font(.title2).foregroundStyle(.green)
                Spacer()
            }
            Text("Charged to \(data.lastChargedTo)% · \(data.lastChargedAt.formatted(date: .omitted, time: .shortened))")
                .font(.footnote).foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                bar("Today", value: data.todayUsagePercent, max: 130, color: .green)
                bar("Daily average", value: data.dailyAveragePercent, max: 130, color: .secondary.opacity(0.35))
                Text(sentence).font(.footnote).foregroundStyle(.secondary).padding(.top, 2)
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private func bar(_ label: String, value: Int, max: Int, color: some ShapeStyle) -> some View {
        HStack(spacing: 10) {
            Text(label).font(.footnote).frame(width: 96, alignment: .leading)
            GeometryReader { g in
                Capsule().fill(color).frame(width: g.size.width * CGFloat(value) / CGFloat(max))
            }
            .frame(height: 10)
            Text("\(value)%").font(.footnote.monospacedDigit()).frame(width: 44, alignment: .trailing)
        }
    }
}
