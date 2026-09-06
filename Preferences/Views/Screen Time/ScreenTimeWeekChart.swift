import SwiftUI

// MARK: - Chart model

/// One stacked bar: segments drawn bottom-up.
struct STBar {
    var segments: [(color: Color, value: Double)]
    var total: Double { segments.reduce(0) { $0 + $1.value } }

    static func single(_ value: Double, _ color: Color) -> STBar {
        STBar(segments: value > 0 ? [(color, value)] : [])
    }
    static let empty = STBar(segments: [])
}

/// Horizontal grid line with an optional right-hand label.
struct STGridLine {
    var value: Double
    var label: String?
    var color: Color = Color(white: 0.25)
}

/// Apple-style Screen Time bar chart drawn with plain SwiftUI so it matches
/// iPadOS pixel for pixel: left-aligned x labels, dashed group separators,
/// thin grid lines, dashed average line and right-hand value labels.
struct STBarChart: View {
    var bars: [STBar]
    var maxValue: Double
    /// Column indices that carry an x label (label sits at the column's leading edge).
    var xLabels: [(index: Int, text: String)]
    /// Dashed vertical separators every `groupSize` columns.
    var groupSize: Int = 1
    var gridLines: [STGridLine] = []
    var average: Double? = nil
    var averageColor: Color = ScreenTimePalette.average
    var averageLabelColor: Color? = nil
    /// Column index that gets a small ▲ marker under the axis (first pickup).
    var marker: Int? = nil
    var plotHeight: CGFloat = 134
    var barWidthRatio: CGFloat = 0.5

    private let labelColumnWidth: CGFloat = 40
    private let xLabelHeight: CGFloat = 22

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                let columns = max(1, bars.count)
                let colWidth = width / CGFloat(columns)
                let barWidth = colWidth * barWidthRatio
                ZStack(alignment: .topLeading) {
                    // Horizontal grid
                    ForEach(Array(gridLines.enumerated()), id: \.offset) { _, line in
                        Rectangle()
                            .fill(line.color)
                            .frame(height: 0.5)
                            .offset(y: y(for: line.value) - 0.25)
                    }
                    // Vertical dashed separators between groups
                    ForEach(0...(columns / max(1, groupSize)), id: \.self) { g in
                        let x = CGFloat(g * groupSize) * colWidth
                        if x <= width + 0.5 {
                            Path { p in
                                p.move(to: CGPoint(x: x, y: 0))
                                p.addLine(to: CGPoint(x: x, y: plotHeight))
                            }
                            .stroke(Color(white: 0.28), style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        }
                    }
                    // Bars
                    ForEach(Array(bars.enumerated()), id: \.offset) { i, bar in
                        let x = CGFloat(i) * colWidth + (colWidth - barWidth) / 2
                        VStack(spacing: 0) {
                            ForEach(Array(bar.segments.reversed().enumerated()), id: \.offset) { _, seg in
                                Rectangle()
                                    .fill(seg.color)
                                    .frame(height: height(for: seg.value))
                            }
                        }
                        .frame(width: barWidth, height: plotHeight, alignment: .bottom)
                        .offset(x: x)
                    }
                    // Average line
                    if let average {
                        Path { p in
                            let yy = y(for: average)
                            p.move(to: CGPoint(x: 0, y: yy))
                            p.addLine(to: CGPoint(x: width, y: yy))
                        }
                        .stroke(averageColor, style: StrokeStyle(lineWidth: 1.2, dash: [3, 3]))
                    }
                    // Baseline
                    Rectangle()
                        .fill(Color(white: 0.30))
                        .frame(height: 0.5)
                        .offset(y: plotHeight - 0.5)
                    // Marker
                    if let marker {
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .offset(x: CGFloat(marker) * colWidth + colWidth / 2 - 4, y: plotHeight + 1)
                    }
                    // X labels (leading edge of the column)
                    ForEach(Array(xLabels.enumerated()), id: \.offset) { _, l in
                        Text(l.text)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .offset(x: CGFloat(l.index) * colWidth + 8, y: plotHeight + 6)
                    }
                }
            }
            .frame(height: plotHeight + xLabelHeight)

            // Right-hand labels
            ZStack(alignment: .topLeading) {
                ForEach(Array(gridLines.enumerated()), id: \.offset) { _, line in
                    if let label = line.label, !collidesWithAverage(line.value) {
                        Text(label)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .offset(y: y(for: line.value) - 9)
                    }
                }
                if let average {
                    Text("avg")
                        .font(.subheadline)
                        .foregroundStyle(averageLabelColor ?? averageColor)
                        .offset(y: y(for: average) - 9)
                }
            }
            .frame(width: labelColumnWidth, height: plotHeight + xLabelHeight, alignment: .topLeading)
        }
    }

    private func height(for value: Double) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        return plotHeight * CGFloat(min(value, maxValue) / maxValue)
    }

    private func y(for value: Double) -> CGFloat {
        plotHeight - height(for: value)
    }

    private func collidesWithAverage(_ value: Double) -> Bool {
        guard let average else { return false }
        return abs(y(for: value) - y(for: average)) < 16
    }
}

// MARK: - Ready-made charts

/// Week chart (7 columns, one letter per day at the column's leading edge).
struct ScreenTimeWeekChart: View {
    var bars: [STBar]
    var labels: [String]
    var unit: Double                 // grid step, e.g. 7h = 420 minutes
    /// Label for a grid value; return nil to leave that line unlabeled.
    var unitLabel: (Double) -> String?
    var average: Double?
    var averageColor: Color = ScreenTimePalette.average
    var averageLabelColor: Color? = nil
    var plotHeight: CGFloat = 134
    var showTopLabel = false
    var showZeroLabel = true

    var body: some View {
        let maxValue = unit * 3
        STBarChart(
            bars: bars,
            maxValue: maxValue,
            xLabels: labels.enumerated().map { ($0.offset, $0.element) },
            groupSize: 1,
            gridLines: [
                STGridLine(value: unit * 3, label: showTopLabel ? unitLabel(unit * 3) : nil),
                STGridLine(value: unit * 2, label: nil),
                STGridLine(value: unit, label: unitLabel(unit)),
                STGridLine(value: 0, label: showZeroLabel ? "0" : nil)
            ],
            average: average,
            averageColor: averageColor,
            averageLabelColor: averageLabelColor,
            plotHeight: plotHeight
        )
    }
}

/// Hourly chart (24 columns, labels 00 / 06 / 12 / 18, separators every 6h).
struct ScreenTimeDayChart: View {
    var bars: [STBar]
    var unit: Double                 // grid step, e.g. 30 minutes or 5 pickups
    var unitLabel: (Double) -> String?
    var plotHeight: CGFloat = 88
    var marker: Int? = nil

    var body: some View {
        STBarChart(
            bars: bars,
            maxValue: unit * 2,
            xLabels: [(0, "00"), (6, "06"), (12, "12"), (18, "18")],
            groupSize: 6,
            gridLines: [
                STGridLine(value: unit * 2, label: unitLabel(unit * 2)),
                STGridLine(value: unit, label: unitLabel(unit)),
                STGridLine(value: 0, label: "0")
            ],
            marker: marker,
            plotHeight: plotHeight,
            barWidthRatio: 0.72
        )
    }
}

// MARK: - Shared pieces

/// "Social 19h 46m · Games 4h 22m · Other 1h 51m" spread across the card.
struct ScreenTimeCategoryLegend: View {
    var totals: [ScreenTimeCategory: Int]
    private let order: [ScreenTimeCategory] = [.social, .games, .other]

    var body: some View {
        HStack(alignment: .top) {
            ForEach(Array(order.enumerated()), id: \.offset) { i, cat in
                VStack(alignment: i == 0 ? .leading : (i == order.count - 1 ? .trailing : .center), spacing: 4) {
                    Text(cat.rawValue).foregroundStyle(cat.color)
                    Text(minutesLabel(totals[cat] ?? 0))
                }
                if i < order.count - 1 { Spacer() }
            }
        }
        .font(.body)
    }
}

/// App row with a proportional usage bar and value, like Most Used.
struct ScreenTimeUsageRow: View {
    var icon: StorageIcon
    var name: String
    var fraction: Double
    var valueText: String
    var barColor: Color = ScreenTimePalette.usageTrack
    var dotColor: Color? = nil

    private let maxBarWidth: CGFloat = 190

    var body: some View {
        HStack(spacing: 14) {
            StorageIconView(icon: icon)
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                HStack(spacing: 8) {
                    ZStack(alignment: .trailing) {
                        Capsule()
                            .fill(barColor)
                            .frame(width: max(8, maxBarWidth * CGFloat(min(max(fraction, 0), 1))), height: 4)
                        if let dotColor {
                            Circle().fill(dotColor).frame(width: 8, height: 8).offset(x: 2)
                        }
                    }
                    Text(valueText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}

/// Section header in the iPadOS 26 style (17pt semibold, secondary).
struct ScreenTimeHeader: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
}
