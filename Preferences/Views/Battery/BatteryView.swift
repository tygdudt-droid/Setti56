import SwiftUI

/// Settings > Battery (iPadOS 26): level card, Daily Usage card with the
/// week chart and the top App and System Activity rows, then Battery Health,
/// Battery Percentage and Low Power Mode.
struct BatteryView: View {
    @Environment(SettingsStore.self) private var store
    @State private var data = BatteryDataProvider.shared

    var body: some View {
        @Bindable var store = store
        CustomList(title: "Battery", topPadding: true) {
            Section {
                BatteryHeaderCard(data: data)
            }

            Section {
                BatteryDailyUsageCard(data: data)
                    .padding(.vertical, 6)

                Text("App and System Activity")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden, edges: .top)

                ForEach(data.summaryUsage) { usage in
                    RouteLink("Battery/App/\(usage.id)") {
                        BatteryAppDetailView(usage: usage)
                    } label: {
                        BatteryAppRow(usage: usage)
                    }
                }

                RouteLink("Battery/Usage") {
                    BatteryUsageView(data: data)
                } label: {
                    Text("View All Battery Usage")
                }
            } header: {
                Text("Daily Usage")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Section {
                RouteLink("Battery/Health") {
                    BatteryHealthView(data: data)
                } label: {
                    LabeledContent("Battery Health") {
                        Text(data.healthStatus).foregroundStyle(.secondary)
                    }
                }
                Toggle("Battery Percentage", isOn: $store.batteryPercentage)
                Toggle("Low Power Mode", isOn: $store.lowPowerMode)
            } footer: {
                Text("\(MockDevice.current.deviceTypeName) will temporarily reduce some background activities, processing speed, and display brightness, and limit certain features such as iCloud syncing, mail fetch, and more.")
            }
        }
    }
}

/// Settings > Battery > View All Battery Usage
struct BatteryUsageView: View {
    let data: BatteryDataProvider
    @State private var showAll = false

    var body: some View {
        CustomList(title: "Battery Usage", topPadding: true) {
            Section {
                BatteryDailyUsageCard(data: data, detailed: true)
                    .padding(.top, 6)

                BatteryHourlyChart(hours: data.hours, sessions: data.chargingSessions)
                    .padding(.top, 26)
                    .padding(.bottom, 6)

                HStack(alignment: .top, spacing: 0) {
                    screenFigure("Screen On", data.screenOnMinutes)
                        .frame(width: 300, alignment: .leading)
                    screenFigure("Screen Off", data.screenOffMinutes)
                    Spacer()
                }
                .padding(.bottom, 6)
            } header: {
                Text("Daily Usage")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Section {
                Text("Battery Usage by App")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)

                ForEach(showAll ? data.appUsage : Array(data.appUsage.prefix(5))) { usage in
                    RouteLink("BatteryUsage/App/\(usage.id)") {
                        BatteryAppDetailView(usage: usage)
                    } label: {
                        BatteryAppRow(usage: usage)
                    }
                }

                Button(showAll ? "Show Less" : "Show More") {
                    withAnimation { showAll.toggle() }
                }
            } header: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("App and System Activity Usage")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Get an idea of how much the battery is used by app and system activity throughout the day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .textCase(nil)
                .padding(.bottom, 4)
            }

            Section {
                Text("Other Battery Usage")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)

                ForEach(data.otherUsage) { usage in
                    RouteLink("BatteryUsage/Other/\(usage.id)") {
                        BatteryAppDetailView(usage: usage)
                    } label: {
                        BatteryAppRow(usage: usage)
                    }
                }
            }
        }
    }

    private func screenFigure(_ title: String, _ minutes: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(.secondary)
            Text(minutesLabel(minutes)).font(.system(size: 24, weight: .regular))
        }
    }
}

/// Settings > Battery > [App]
struct BatteryAppDetailView: View {
    let usage: BatteryAppUsage

    var body: some View {
        CustomList(title: usage.name, topPadding: true) {
            Section {
                HStack(spacing: 14) {
                    StorageIconView(icon: usage.icon)
                        .scaleEffect(2)
                        .frame(width: 58, height: 58)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(usage.name).font(.title3.weight(.semibold))
                        Text("\(usage.percent)% of battery").foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                if let onScreen = usage.onScreen {
                    LabeledContent("On Screen", value: minutesLabel(onScreen))
                }
                if let background = usage.background {
                    LabeledContent("Background", value: minutesLabel(background))
                }
            } footer: {
                if let note = usage.note { Text(note) }
            }
        }
    }
}

/// Settings > Battery > Battery Health > Charge Limit (kept for the mock
/// charge-limit slider used elsewhere).
struct ChargeLimitView: View {
    @Environment(SettingsStore.self) private var store

    var body: some View {
        @Bindable var store = store
        CustomList(title: "Charge Limit", topPadding: true) {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(store.chargeLimit)%").font(.title.bold())
                    Slider(
                        value: Binding(
                            get: { Double(store.chargeLimit) },
                            set: { store.chargeLimit = Int(($0 / 5).rounded() * 5) }
                        ),
                        in: 80...100, step: 5
                    )
                }
                .padding(.vertical, 6)
            } footer: {
                Text("Choose a charge limit between 80% and 100%. Limiting charge to a lower percentage can help improve battery lifespan.")
            }
            Section {
                Toggle("Optimized Battery Charging", isOn: $store.optimizedCharging)
            } footer: {
                Text("To reduce battery aging, \(MockDevice.current.deviceTypeName) learns from your daily charging routine so it can wait to finish charging past \(store.chargeLimit)% until you need to use it.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        BatteryView()
    }
    .environment(SettingsStore.shared)
    .environment(PrimarySettingsListModel())
}
