import SwiftUI

/// Screen Time > See All App & Website Activity — the "[Device name]" page.
/// Week / Day segmented control, Screen Time card (charts + category legend),
/// Most Used, Pickups and Notifications cards, plus the "< This Week >"
/// navigator that pins under the title once the page is scrolled.
struct ScreenTimeActivityView: View {
    enum Mode: Hashable { case week, day }

    let provider: ScreenTimeProvider
    @AppStorage("DeviceName") private var deviceName = UIDevice.current.model
    @State private var mode: Mode = .week
    @State private var dayIndex: Int
    @State private var weekOffset = 0
    @State private var showCategories = false
    @State private var showMoreUsage = false
    @State private var showMorePickups = false
    @State private var scrolled = false

    init(provider: ScreenTimeProvider) {
        self.provider = provider
        _dayIndex = State(initialValue: provider.todayIndex)
    }

    // MARK: Derived data

    private var isCurrentWeek: Bool { weekOffset == 0 }
    private var week: [ScreenTimeDay] {
        isCurrentWeek ? provider.week : provider.week.map { .empty($0.date) }
    }
    private var day: ScreenTimeDay { provider.week[dayIndex] }
    private var labels: [String] { provider.weekdayInitials }

    private var periodTitle: String {
        switch mode {
        case .week: return weekOffset == 0 ? "This Week" : (weekOffset == -1 ? "Last Week" : "\(-weekOffset) Weeks Ago")
        case .day: return ScreenTimeProvider.dayTitle(day.date)
        }
    }
    private var canGoForward: Bool {
        mode == .week ? weekOffset < 0 : dayIndex < provider.todayIndex
    }
    private var canGoBack: Bool {
        mode == .week ? true : dayIndex > 0
    }

    private func categoryBar(_ d: ScreenTimeDay) -> STBar {
        var social = 0, games = 0, other = 0
        for b in d.hourly {
            social += b[.social] ?? 0
            games += b[.games] ?? 0
            other += b[.other] ?? 0
        }
        var segs: [(color: Color, value: Double)] = []
        if social > 0 { segs.append((ScreenTimeCategory.social.color, Double(social))) }
        if games > 0 { segs.append((ScreenTimeCategory.games.color, Double(games))) }
        if other > 0 { segs.append((ScreenTimeCategory.other.color, Double(other))) }
        return STBar(segments: segs)
    }

    /// Week chart bars in Day mode: the selected day keeps its colors, the
    /// rest are dimmed gray.
    private func dayModeWeekBars(value: (ScreenTimeDay) -> Double, color: Color, stacked: Bool) -> [STBar] {
        provider.week.enumerated().map { (i, d) -> STBar in
            if i == dayIndex {
                return stacked ? categoryBar(d) : STBar.single(value(d), color)
            }
            return STBar.single(value(d), ScreenTimePalette.dimmedBar)
        }
    }

    private var mostUsed: [STAppValue] {
        mode == .week ? (isCurrentWeek ? provider.weekMostUsed : []) : day.mostUsed
    }
    private var firstUsed: [STAppValue] {
        mode == .week ? (isCurrentWeek ? provider.weekFirstUsedAfterPickup : []) : day.firstUsedAfterPickup
    }
    private var notificationsByApp: [STAppValue] {
        mode == .week ? (isCurrentWeek ? provider.weekNotificationsByApp : []) : day.notificationsByApp
    }
    private var categoryTotals: [ScreenTimeCategory: Int] {
        mode == .week ? (isCurrentWeek ? provider.weekCategoryTotals : [:]) : day.categoryTotals
    }

    // MARK: Body

    var body: some View {
        CustomList(title: deviceName, topPadding: true) {
            Section {
                Picker("", selection: $mode) {
                    Text("Week").tag(Mode.week)
                    Text("Day").tag(Mode.day)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            screenTimeSection
            mostUsedSection
            pickupsSection
            notificationsSection
        }
        .onScrollGeometryChange(for: Bool.self) { geo in
            geo.contentOffset.y + geo.contentInsets.top > 56
        } action: { _, isScrolled in
            withAnimation(.easeInOut(duration: 0.2)) { scrolled = isScrolled }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if scrolled {
                periodNavigator
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: "< This Week >"
    private var periodNavigator: some View {
        HStack {
            navButton("chevron.left", enabled: canGoBack) { goBack() }
            Spacer()
            Text(periodTitle)
            Spacer()
            navButton("chevron.right", enabled: canGoForward) { goForward() }
        }
        .frame(maxWidth: SettingsReadableWidth.maxContentWidth)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }

    private func navButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .foregroundStyle(enabled ? Color.blue : Color.secondary)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color(white: 0.2)))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func goBack() {
        withAnimation {
            if mode == .week { weekOffset -= 1 } else if dayIndex > 0 { dayIndex -= 1 }
        }
    }
    private func goForward() {
        withAnimation {
            if mode == .week { weekOffset = min(0, weekOffset + 1) } else { dayIndex = min(provider.todayIndex, dayIndex + 1) }
        }
    }

    // MARK: Screen Time card
    private var screenTimeSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                if mode == .week {
                    Text("Daily Average").foregroundStyle(.secondary)
                    Text(minutesLabel(isCurrentWeek ? provider.dailyAverage : 0))
                        .font(.system(size: 36, weight: .regular))
                        .padding(.top, 2)
                    ScreenTimeWeekChart(
                        bars: week.map { categoryBar($0) },
                        labels: labels,
                        unit: 420,
                        unitLabel: { "\(Int($0 / 60))h" },
                        average: isCurrentWeek ? Double(provider.dailyAverage) : nil
                    )
                    .padding(.top, 18)
                } else {
                    Text(ScreenTimeProvider.dayTitle(day.date)).foregroundStyle(.secondary)
                    Text(minutesLabel(day.total))
                        .font(.system(size: 36, weight: .regular))
                        .padding(.top, 2)
                    ScreenTimeWeekChart(
                        bars: dayModeWeekBars(value: { Double($0.total) }, color: ScreenTimePalette.cyan, stacked: true),
                        labels: labels,
                        unit: 420,
                        unitLabel: { "\(Int($0 / 60))h" },
                        average: Double(provider.dailyAverage),
                        averageColor: Color(white: 0.75),
                        averageLabelColor: .secondary
                    )
                    .padding(.top, 18)
                    ScreenTimeDayChart(
                        bars: day.hourly.map { categoryBarHour($0) },
                        unit: 30,
                        unitLabel: { "\(Int($0))m" }
                    )
                    .padding(.top, 22)
                }
                ScreenTimeCategoryLegend(totals: categoryTotals)
                    .padding(.top, 14)
            }
            .padding(.vertical, 6)

            if mode == .week {
                LabeledContent("Total Screen Time", value: minutesLabel(isCurrentWeek ? provider.weekTotalReported : 0))
            }
        } header: {
            ScreenTimeHeader(title: "Screen Time")
        } footer: {
            Text(ScreenTimeProvider.updatedLabel)
                .font(.subheadline)
                .padding(.top, 6)
        }
    }

    private func categoryBarHour(_ bucket: [ScreenTimeCategory: Int]) -> STBar {
        var segs: [(color: Color, value: Double)] = []
        for cat in [ScreenTimeCategory.social, .games, .other] {
            if let v = bucket[cat], v > 0 { segs.append((cat.color, Double(v))) }
        }
        return STBar(segments: segs)
    }

    // MARK: Most Used
    private var mostUsedSection: some View {
        Section {
            if showCategories {
                let cats: [(ScreenTimeCategory, Int)] = [ScreenTimeCategory.social, .games, .other].map { ($0, categoryTotals[$0] ?? 0) }
                let maxV = max(1, cats.map(\.1).max() ?? 1)
                ForEach(Array(cats.enumerated()), id: \.offset) { _, item in
                    ScreenTimeUsageRow(
                        icon: .app(bundleID: nil, symbol: categorySymbol(item.0), tint: categoryTint(item.0)),
                        name: item.0.rawValue,
                        fraction: Double(item.1) / Double(maxV),
                        valueText: minutesLabel(item.1),
                        barColor: item.0.color
                    )
                }
            } else {
                let maxV = max(1, mostUsed.first?.value ?? 1)
                let visible = showMoreUsage ? mostUsed : Array(mostUsed.prefix(7))
                ForEach(visible) { u in
                    RouteLink("ScreenTime/App/\(u.app.id)") {
                        ScreenTimeAppDetailView(app: u.app, minutes: u.value)
                    } label: {
                        ScreenTimeUsageRow(icon: u.app.icon, name: u.app.name,
                                           fraction: Double(u.value) / Double(maxV),
                                           valueText: minutesLabel(u.value))
                    }
                }
                if mostUsed.count > 7 && !showMoreUsage {
                    Button("Show More") { withAnimation { showMoreUsage = true } }
                }
                if mostUsed.isEmpty {
                    Text("No Data").foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack {
                ScreenTimeHeader(title: "Most Used")
                Spacer()
                Button(showCategories ? "Show Apps & Websites" : "Show Categories") {
                    withAnimation { showCategories.toggle() }
                }
                .font(.headline)
                .textCase(nil)
            }
        }
    }

    private func categorySymbol(_ c: ScreenTimeCategory) -> String {
        switch c {
        case .social: return "person.2.fill"
        case .games: return "gamecontroller.fill"
        default: return "square.grid.2x2.fill"
        }
    }
    private func categoryTint(_ c: ScreenTimeCategory) -> String {
        switch c {
        case .social: return "0A84FF"
        case .games: return "30D4E6"
        default: return "FF9F0A"
        }
    }

    // MARK: Pickups
    private var pickupsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                if mode == .week {
                    Text("Daily Average").foregroundStyle(.secondary)
                    Text("\(isCurrentWeek ? provider.averagePickups : 0)")
                        .font(.system(size: 36, weight: .regular))
                        .padding(.top, 2)
                    ScreenTimeWeekChart(
                        bars: week.map { .single(Double($0.pickups), ScreenTimePalette.cyan) },
                        labels: labels,
                        unit: 10,
                        unitLabel: { _ in nil },
                        average: isCurrentWeek ? Double(provider.averagePickups) : nil,
                        plotHeight: 56
                    )
                    .padding(.top, 18)
                    HStack(alignment: .top) {
                        statColumn("Most Pickups", provider.mostPickupsDay.map { "\(ScreenTimeProvider.weekdayName($0.date)): \($0.pickups)" } ?? "—")
                            .frame(width: 250, alignment: .leading)
                        statColumn("Total Pickups", "\(isCurrentWeek ? provider.weekPickups : 0)")
                    }
                    .padding(.top, 16)
                } else {
                    Text(ScreenTimeProvider.dayTitle(day.date)).foregroundStyle(.secondary)
                    Text("\(day.pickups)")
                        .font(.system(size: 36, weight: .regular))
                        .padding(.top, 2)
                    ScreenTimeWeekChart(
                        bars: dayModeWeekBars(value: { Double($0.pickups) }, color: ScreenTimePalette.cyan, stacked: false),
                        labels: labels,
                        unit: 10,
                        unitLabel: { _ in nil },
                        average: Double(provider.averagePickups),
                        averageColor: Color(white: 0.75),
                        averageLabelColor: .secondary,
                        plotHeight: 56
                    )
                    .padding(.top, 18)
                    ScreenTimeDayChart(
                        bars: day.pickupsHourly.map { .single(Double($0), ScreenTimePalette.cyan) },
                        unit: 5,
                        unitLabel: { "\(Int($0))" },
                        plotHeight: 62,
                        marker: day.firstPickupHour
                    )
                    .padding(.top, 22)
                    HStack(alignment: .top) {
                        statColumn("First Pickup", day.firstPickupHour.map { String(format: "%02d:00", $0) } ?? "—", marker: day.firstPickupHour != nil)
                            .frame(width: 250, alignment: .leading)
                        statColumn("Total Pickups", "\(day.pickups)")
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.vertical, 6)

            if !firstUsed.isEmpty {
                ScreenTimeHeader(title: "First Used After Pickup")
                    .listRowSeparator(.hidden, edges: .bottom)
                let maxV = max(1, firstUsed.first?.value ?? 1)
                let visible = showMorePickups ? firstUsed : Array(firstUsed.prefix(4))
                ForEach(visible) { u in
                    RouteLink("ScreenTime/Pickup/\(u.app.id)") {
                        ScreenTimeAppDetailView(app: u.app, minutes: nil)
                    } label: {
                        ScreenTimeUsageRow(icon: u.app.icon, name: u.app.name,
                                           fraction: Double(u.value) / Double(maxV),
                                           valueText: "\(u.value)",
                                           barColor: ScreenTimePalette.cyan)
                    }
                }
                if firstUsed.count > 4 && !showMorePickups {
                    Button("Show More") { withAnimation { showMorePickups = true } }
                }
            }
        } header: {
            ScreenTimeHeader(title: "Pickups")
        }
    }

    private func statColumn(_ title: String, _ value: String, marker: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                if marker {
                    Image(systemName: "arrowtriangle.up.fill").font(.system(size: 9)).foregroundStyle(.secondary)
                }
                Text(value)
            }
        }
    }

    // MARK: Notifications
    private var notificationsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                if mode == .week {
                    Text("Daily Average").foregroundStyle(.secondary)
                    bigNumberWithDot("\(isCurrentWeek ? provider.averageNotifications : 0)")
                    STBarChart(
                        bars: week.map { .single(Double($0.notifications), ScreenTimePalette.notification) },
                        maxValue: 10,
                        xLabels: labels.enumerated().map { ($0.offset, $0.element) },
                        gridLines: [STGridLine(value: 10, label: "10"), STGridLine(value: 5), STGridLine(value: 0)],
                        average: isCurrentWeek ? Double(provider.averageNotifications) : nil,
                        plotHeight: 58
                    )
                    .padding(.top, 18)
                } else {
                    Text(ScreenTimeProvider.dayTitle(day.date)).foregroundStyle(.secondary)
                    bigNumberWithDot("\(day.notifications)")
                    STBarChart(
                        bars: dayModeWeekBars(value: { Double($0.notifications) }, color: ScreenTimePalette.notification, stacked: false),
                        maxValue: 10,
                        xLabels: labels.enumerated().map { ($0.offset, $0.element) },
                        gridLines: [STGridLine(value: 10, label: "10"), STGridLine(value: 5), STGridLine(value: 0)],
                        average: Double(provider.averageNotifications),
                        averageColor: Color(white: 0.75),
                        averageLabelColor: .secondary,
                        plotHeight: 58
                    )
                    .padding(.top, 18)
                    ScreenTimeDayChart(
                        bars: day.notificationsHourly.map { .single(Double($0), ScreenTimePalette.notification) },
                        unit: 5,
                        unitLabel: { "\(Int($0))" },
                        plotHeight: 62
                    )
                    .padding(.top, 22)
                }
            }
            .padding(.vertical, 6)

            let maxV = max(1, notificationsByApp.first?.value ?? 1)
            ForEach(notificationsByApp) { u in
                RouteLink("ScreenTime/Notif/\(u.app.id)") {
                    ScreenTimeAppDetailView(app: u.app, minutes: nil)
                } label: {
                    ScreenTimeUsageRow(icon: u.app.icon, name: u.app.name,
                                       fraction: Double(u.value) / Double(maxV),
                                       valueText: "\(u.value)",
                                       dotColor: ScreenTimePalette.notification)
                }
            }
        } header: {
            ScreenTimeHeader(title: "Notifications")
        }
    }

    private func bigNumberWithDot(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(text).font(.system(size: 36, weight: .regular))
            Circle().fill(ScreenTimePalette.notification).frame(width: 9, height: 9).padding(.top, 8)
        }
        .padding(.top, 2)
    }
}

/// Screen Time > [App] — simple per-app page.
struct ScreenTimeAppDetailView: View {
    let app: STApp
    let minutes: Int?

    var body: some View {
        CustomList(title: app.name, topPadding: true) {
            Section {
                HStack(spacing: 14) {
                    StorageIconView(icon: app.icon)
                        .scaleEffect(2)
                        .frame(width: 58, height: 58)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name).font(.title3.weight(.semibold))
                        Text(app.category.rawValue).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                if let minutes {
                    LabeledContent("Screen Time", value: minutesLabel(minutes))
                }
            }
            Section {
                Button("Add Limit") {}
            } footer: {
                Text("Set a daily time limit for this app.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScreenTimeActivityView(provider: ScreenTimeProvider.shared)
    }
    .environment(PrimarySettingsListModel())
}
