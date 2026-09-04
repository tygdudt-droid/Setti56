import SwiftUI

struct BatteryView: View {
    @Environment(SettingsStore.self) private var store
    @State private var data = BatteryDataProvider.shared
    @State private var range = 0                     // 0 = Last 24 Hours, 1 = Last 10 Days
    @State private var selectedTime: Date?
    @State private var selectedDay: Date?
    @State private var showActivity = false

    private var apps: [AppBatteryUsage] {
        if range == 1, let day = data.last10d.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDay ?? .distantPast) }) {
            return day.apps
        }
        return data.todayApps
    }

    var body: some View {
        @Bindable var store = store
        List {
            Section { BatteryHeaderCard(data: data) }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            Section {
                Toggle("Low Power Mode", isOn: $store.lowPowerMode)
                if MockDevice.current.supportsAdaptivePower {
                    Toggle("Adaptive Power", isOn: $store.adaptivePower)
                }
            } header: { Text("Power Mode") } footer: {
                Text(MockDevice.current.supportsAdaptivePower
                     ? "Adaptive Power makes small performance adjustments when battery usage is higher than usual, including slightly lowering display brightness or allowing some activities to take a little longer."
                     : "Low Power Mode temporarily reduces background activity like downloads and mail fetch until you can fully charge your \(MockDevice.current.deviceTypeName).")
            }

            Section {
                NavigationLink { ChargeLimitView() } label: { LabeledContent("Charge Limit", value: "\(store.chargeLimit)%") }
                NavigationLink { BatteryHealthView(data: data) } label: {
                    LabeledContent("Battery Health", value: data.maximumCapacity >= 80 ? "Normal" : "Service")
                }
            } header: { Text("Charging") } footer: {
                Text("Last charged to \(data.lastChargedTo)% \(data.lastChargedAt.formatted(date: .omitted, time: .shortened)).")
            }

            Section { Toggle("Battery Percentage", isOn: $store.batteryPercentage) }

            Section {
                Picker("", selection: $range) {
                    Text("Last 24 Hours").tag(0)
                    Text("Last 10 Days").tag(1)
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)

                Group {
                    if range == 0 {
                        BatteryLevelChart(samples: data.last24h, selection: $selectedTime)
                    } else {
                        BatteryTenDayChart(days: data.last10d, selection: $selectedDay)
                    }
                }
                .listRowSeparator(.hidden)
                BatteryLegend()
                    .listRowSeparator(.hidden)
            } header: { Text(range == 0 ? "Battery Level" : "Battery Usage") }

            Section {
                LabeledContent("Screen On", value: minutesLabel(range == 0 ? data.screenOnMinutesToday : (selectedDayData?.screenOnMinutes ?? data.screenOnMinutesToday)))
                LabeledContent("Screen Off", value: minutesLabel(range == 0 ? data.screenOffMinutesToday : (selectedDayData?.screenOffMinutes ?? data.screenOffMinutesToday)))
            } header: { Text(range == 0 ? "Screen Usage" : "Average Screen Usage") }

            Section {
                Toggle("Show Activity", isOn: $showActivity)
                ForEach(apps) { app in BatteryAppRow(usage: app, showActivity: showActivity) }
            } header: {
                HStack {
                    Text(showActivity ? "Activity by App" : "Battery Usage by App")
                    Spacer()
                    if range == 1, let d = selectedDay { Text(d.formatted(.dateTime.weekday(.abbreviated))).textCase(nil) }
                }
            }

            Section("Insights & Suggestions") {
                HStack(spacing: 12) {
                    Image(systemName: "sun.max.fill").foregroundStyle(.white).frame(width: 29, height: 29)
                        .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.blue))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Auto-Brightness")
                        Text("Display brightness accounted for a large portion of your battery usage.").font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Battery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedDayData: BatteryDay? {
        guard let selectedDay else { return nil }
        return data.last10d.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }
    }
}

struct BatteryAppRow: View {
    let usage: AppBatteryUsage
    let showActivity: Bool
    var body: some View {
        HStack(spacing: 12) {
            AppIconView(app: usage.app, side: 29)
            VStack(alignment: .leading, spacing: 2) {
                Text(usage.app.name)
                if usage.backgroundMinutes > 0 {
                    Text("Background Activity").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if showActivity {
                Text(minutesLabel(usage.screenOnMinutes + usage.backgroundMinutes)).foregroundStyle(.secondary)
            } else {
                Text("\(Int((usage.energyShare * 100).rounded()))%").foregroundStyle(.secondary)
            }
        }
    }
}

struct BatteryLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            item(.green, "Battery Level")
            item(.green.opacity(0.35), "Charging")
            item(.yellow, "Low Power Mode")
        }
        .font(.caption).foregroundStyle(.secondary)
    }
    private func item(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 4) { RoundedRectangle(cornerRadius: 2).fill(c).frame(width: 10, height: 10); Text(t) }
    }
}

struct ChargeLimitView: View {
    @Environment(SettingsStore.self) private var store
    var body: some View {
        @Bindable var store = store
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("\(store.chargeLimit)%").font(.title.bold())
                    Slider(value: Binding(get: { Double(store.chargeLimit) }, set: { store.chargeLimit = Int(($0 / 5).rounded() * 5) }), in: 80...100, step: 5)
                }
            } footer: {
                Text("Choose a charge limit between 80% and 100%. Limiting charge to a lower percentage can help improve battery lifespan.")
            }
            Section { Toggle("Optimized Battery Charging", isOn: $store.optimizedCharging) } footer: {
                Text("To reduce battery aging, \(MockDevice.current.deviceTypeName) learns from your daily charging routine so it can wait to finish charging past \(store.chargeLimit)% until you need to use it.")
            }
        }
        .navigationTitle("Charge Limit")
        .navigationBarTitleDisplayMode(.inline)
    }
}
