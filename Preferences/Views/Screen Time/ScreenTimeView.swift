import SwiftUI

struct ScreenTimeView: View {
    @State private var provider = ScreenTimeProvider.shared
    @AppStorage("screentime.share") private var shareAcrossDevices = false
    @AppStorage("screentime.enabled") private var enabled = true
    @State private var confirmOff = false

    var body: some View {
        List {
            if enabled {
                Section { ScreenTimeCard(provider: provider) }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                Section {
                    NavigationLink { ScreenTimeActivityView(provider: provider) } label: { LabeledContent("App & Website Activity", value: "On") }
                }
                Section("Limit Usage") {
                    link("Downtime", "moon.fill", .indigo) { DowntimeView() }
                    link("App Limits", "hourglass", .orange) { AppLimitsView() }
                    link("Always Allowed", "checkmark.circle.fill", .green) { AlwaysAllowedView() }
                    link("Screen Distance", "eyeglasses", .teal) { ScreenDistanceView() }
                }
                Section("Communication") {
                    link("Communication Limits", "person.2.fill", .green) { ContentUnavailableView("Communication Limits", systemImage: "person.2.fill") }
                    link("Communication Safety", "bubble.left.and.exclamationmark.bubble.right.fill", .blue) { ContentUnavailableView("Communication Safety", systemImage: "bubble.left.fill") }
                }
                Section("Restrictions") {
                    link("Content & Privacy Restrictions", "nosign", .red) { ContentPrivacyGateView() }
                }
                Section { link("Set Up Screen Time for Family", "figure.2.and.child.holdinghands", .blue) { ContentUnavailableView("Family", systemImage: "figure.2.and.child.holdinghands") } } footer: {
                    Text("Set up Family Sharing to use Screen Time with your family’s devices.")
                }
                Section { link("Lock Screen Time Settings", "lock.fill", .gray) { ContentUnavailableView("Lock Screen Time Settings", systemImage: "lock.fill") } } footer: {
                    Text("Use a passcode to secure Screen Time settings.")
                }
                Section { Toggle("Share Across Devices", isOn: $shareAcrossDevices) } footer: {
                    Text("You can enable this on any device signed in to iCloud to report your combined screen time.")
                }
                Section {
                    Button("Turn Off App & Website Activity", role: .destructive) { confirmOff = true }
                }
            } else {
                Section {
                    Button("Turn On App & Website Activity") { withAnimation { enabled = true } }
                } footer: { Text("Get reports about your screen time and set limits for what you want to manage.") }
            }
        }
        .navigationTitle("Screen Time")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Turn Off App & Website Activity?", isPresented: $confirmOff, titleVisibility: .visible) {
            Button("Turn Off App & Website Activity", role: .destructive) { withAnimation { enabled = false } }
        } message: { Text("Reports and limits will be turned off and your activity data will be deleted.") }
    }

    private func link<D: View>(_ title: String, _ icon: String, _ color: Color, @ViewBuilder destination: @escaping () -> D) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(.white).font(.footnote.weight(.semibold))
                    .frame(width: 29, height: 29)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
                Text(title)
            }
        }
    }
}

struct ScreenTimeCard: View {
    let provider: ScreenTimeProvider
    @State private var selectedDay: Date?
    var body: some View {
        NavigationLink { ScreenTimeActivityView(provider: provider) } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Text(MockDevice.current.deviceName).font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
                }
                Text("DAILY AVERAGE").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(minutesLabel(provider.dailyAverage)).font(.title.bold())
                    DeltaPill(percent: provider.deltaPercent)
                }
                ScreenTimeWeekChart(days: provider.week, average: provider.dailyAverage, selectedDay: $selectedDay)
                LegendRow(categories: provider.weekTopCategories)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DeltaPill: View {
    let percent: Int
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: percent >= 0 ? "arrow.up" : "arrow.down").font(.caption2.bold())
            Text("\(abs(percent))% from last week").font(.caption)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Capsule().fill((percent >= 0 ? Color.red : Color.green).opacity(0.15)))
        .foregroundStyle(percent >= 0 ? .red : .green)
    }
}

struct LegendRow: View {
    let categories: [ScreenTimeCategory]
    var body: some View {
        HStack(spacing: 14) {
            ForEach(categories, id: \.self) { c in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(c.color).frame(width: 10, height: 10)
                    Text(c.rawValue).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
        }
    }
}
