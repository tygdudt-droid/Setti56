import SwiftUI

/// Settings > Screen Time (iPadOS 26).
///
/// With App & Website Activity on: device-name header, overview card
/// (Daily Average + week chart + "See All App & Website Activity"), then
/// Limit Usage / Communication / Restrictions cards and the footer actions.
/// With it off: the Screen Time header card and an "App & Website Activity"
/// row instead of the chart.
struct ScreenTimeView: View {
    @State private var provider = ScreenTimeProvider.shared
    @AppStorage("screentime.share") private var shareAcrossDevices = true
    @AppStorage("screentime.enabled") private var enabled = true
    @AppStorage("DeviceName") private var deviceName = UIDevice.current.model
    @State private var confirmOff = false

    var body: some View {
        CustomList(title: "Screen Time", topPadding: true) {
            if enabled {
                overviewSection
            } else {
                ScreenTimeHeaderCard()
            }

            // MARK: Limit Usage
            Section {
                if !enabled {
                    row("App & Website Activity", "Reports, Downtime & App Limits", "chart.bar.fill", "0A84FF") {
                        ScreenTimeActivityOffView()
                    }
                } else {
                    row("Downtime", "Schedule time away from the screen", "moon.fill", "5E5CE6") { DowntimeView() }
                    row("App Limits", "Set time limits for apps", "hourglass", "FF9F0A") { AppLimitsView() }
                    row("Always Allowed", "Choose apps to allow at all times", "checkmark.shield.fill", "30D158") { AlwaysAllowedView() }
                }
                row("Screen Distance", "Reduce eye strain", "arrow.up.to.line.compact", "0A84FF") { ScreenDistanceView() }
            } header: {
                ScreenTimeHeader(title: "Limit Usage")
            }

            // MARK: Communication
            Section {
                row("Communication Limits", "Set limits for calling and messaging", "person.circle.fill", "30D158") {
                    ContentUnavailableView("Communication Limits", systemImage: "person.circle.fill")
                }
                row("Communication Safety", "Protect from sensitive content", "bubble.left.and.exclamationmark.bubble.right.fill", "0A84FF") {
                    ContentUnavailableView("Communication Safety", systemImage: "bubble.left.and.exclamationmark.bubble.right.fill")
                }
            } header: {
                ScreenTimeHeader(title: "Communication")
            }

            // MARK: Restrictions
            Section {
                row("Content & Privacy Restrictions", "Manage content, apps, and settings", "nosign", "FF453A") {
                    ContentPrivacyGateView()
                }
            } header: {
                ScreenTimeHeader(title: "Restrictions")
            }

            Section {
                Button("Lock Screen Time Settings") {}
            } footer: {
                Text("Use a passcode to secure Screen Time settings.")
            }

            Section {
                Toggle("Share Across Devices", isOn: $shareAcrossDevices)
            } footer: {
                Text("You can enable this on any device signed in to iCloud to sync your Screen Time settings.")
            }

            Section {
                Button("Set Up Screen Time for Family") {}
            } footer: {
                Text("Set up Family Sharing to use Screen Time with your family’s devices.")
            }

            if enabled {
                Section {
                    Button("Turn off App & Website Activity", role: .destructive) { confirmOff = true }
                } footer: {
                    Text("Turning off App & Website Activity disables real-time reporting, Downtime, App Limits, and Always Allowed.")
                }
            }
        }
        .confirmationDialog("Turn Off App & Website Activity?", isPresented: $confirmOff, titleVisibility: .visible) {
            Button("Turn Off App & Website Activity", role: .destructive) {
                withAnimation { enabled = false }
            }
        } message: {
            Text("Reports and limits will be turned off and your activity data will be deleted.")
        }
    }

    // MARK: Overview card
    private var overviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                Text("Daily Average")
                    .foregroundStyle(.secondary)
                Text(minutesLabel(provider.dailyAverage))
                    .font(.system(size: 36, weight: .regular))
                    .padding(.top, 2)
                ScreenTimeWeekChart(
                    bars: provider.week.map { .single(Double($0.total), ScreenTimePalette.cyan) },
                    labels: provider.weekdayInitials,
                    unit: 420,
                    unitLabel: { "\(Int($0 / 60))h" },
                    average: Double(provider.dailyAverage)
                )
                .padding(.top, 18)
            }
            .padding(.vertical, 6)

            RouteLink("ScreenTime/Activity") {
                ScreenTimeActivityView(provider: provider)
            } label: {
                Text("See All App & Website Activity")
            }
        } header: {
            ScreenTimeHeader(title: deviceName)
        } footer: {
            Text(ScreenTimeProvider.updatedLabel)
                .font(.subheadline)
                .padding(.top, 6)
        }
    }

    private func row<D: View>(_ title: String, _ subtitle: String, _ symbol: String, _ tint: String,
                              @ViewBuilder destination: @escaping () -> D) -> some View {
        RouteLink("ScreenTime/\(title)", destination: destination) {
            HStack(spacing: 14) {
                StorageIconView(icon: .app(bundleID: nil, symbol: symbol, tint: tint))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

/// Purple hourglass tile + title + description, shown when App & Website
/// Activity is off (and on its own page).
struct ScreenTimeHeaderCard: View {
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(LinearGradient(colors: [Color(red: 0.49, green: 0.47, blue: 0.98), Color(red: 0.36, green: 0.34, blue: 0.90)],
                                             startPoint: .top, endPoint: .bottom))
                    Image(systemName: "hourglass")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(width: 58, height: 58)
                Text("Screen Time")
                    .font(.title2.weight(.bold))
                    .padding(.top, 18)
                Text("Get insights about your screen time and set limits as needed. Adults can also set parental controls for a child’s device.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(.vertical, 8)
        }
    }
}

/// Screen Time > App & Website Activity (while it is turned off).
struct ScreenTimeActivityOffView: View {
    @AppStorage("screentime.enabled") private var enabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CustomList(title: "App & Website Activity", topPadding: true) {
            ScreenTimeHeaderCard()
            Section {
                Button("Turn On App & Website Activity") {
                    withAnimation { enabled = true }
                    dismiss()
                }
            } footer: {
                Text("Get real-time reports about your screen time and set limits for what you want to manage.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScreenTimeView()
    }
    .environment(PrimarySettingsListModel())
    .environment(SettingsStore.shared)
}
