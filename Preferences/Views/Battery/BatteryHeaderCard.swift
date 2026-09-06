import SwiftUI

/// Top card of Settings > Battery: big percentage, ⓘ button, last-charge
/// line and the level track.
struct BatteryHeaderCard: View {
    let data: BatteryDataProvider
    @State private var showingInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(data.currentLevel)")
                        .font(.system(size: 34, weight: .bold))
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

            Text("Last Charged to \(data.lastChargedTo)%: \(data.lastChargedAgo)")
                .padding(.top, 4)

            levelTrack
                .padding(.top, 14)
        }
        .padding(.vertical, 4)
        .alert("Battery Level", isPresented: $showingInfo) {
            Button("OK") {}
        } message: {
            Text("The bar shows the current charge level. \(MockDevice.current.deviceTypeName) was last charged to \(data.lastChargedTo)% \(data.lastChargedAgo).")
        }
    }

    private var levelTrack: some View {
        GeometryReader { geo in
            let filled = geo.size.width * CGFloat(data.currentLevel) / 100
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
/// the sentence, Average / Today figures, chart and legend.
struct BatteryDailyUsageCard: View {
    let data: BatteryDataProvider
    /// Full report style (percent axis labels, date sub-labels, callout).
    var detailed = false

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
                    figure("Today", "\(data.todayPercent)", color: BatteryPalette.today, labelColor: BatteryPalette.today)
                    Spacer()
                }
                .padding(.bottom, 10)
            }

            BatteryDailyUsageChart(days: data.days, average: data.averagePercent, detailed: detailed)
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
                Text("%").font(.system(size: 18, weight: .regular))
            }
            .foregroundStyle(color)
        }
    }
}
