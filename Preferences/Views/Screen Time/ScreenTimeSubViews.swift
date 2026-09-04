import SwiftUI

struct DowntimeView: View {
    @AppStorage("downtime.scheduled") private var scheduled = false
    @AppStorage("downtime.from") private var from = Date.now.timeIntervalSince1970
    @AppStorage("downtime.to") private var to = Date.now.timeIntervalSince1970
    @AppStorage("downtime.block") private var blockAtDowntime = false
    var body: some View {
        List {
            Section { Button("Turn On Downtime Until Tomorrow") {} } footer: {
                Text("Set a schedule for time away from the screen. During downtime, only apps that you choose to allow and phone calls will be available.")
            }
            Section {
                Toggle("Scheduled", isOn: $scheduled)
                if scheduled {
                    DatePicker("From", selection: Binding(get: { Date(timeIntervalSince1970: from) }, set: { from = $0.timeIntervalSince1970 }), displayedComponents: .hourAndMinute)
                    DatePicker("To", selection: Binding(get: { Date(timeIntervalSince1970: to) }, set: { to = $0.timeIntervalSince1970 }), displayedComponents: .hourAndMinute)
                }
            }
            Section { Toggle("Block at Downtime", isOn: $blockAtDowntime) } footer: {
                Text("Apps that are not allowed will be blocked during downtime.")
            }
        }
        .navigationTitle("Downtime")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppLimitsView: View {
    struct Limit: Identifiable { let id = UUID(); let category: ScreenTimeCategory; let minutes: Int }
    @State private var limits: [Limit] = [Limit(category: .social, minutes: 90)]
    @State private var adding = false
    @AppStorage("applimits.enabled") private var enabled = true
    var body: some View {
        List {
            Section {
                Toggle("App Limits", isOn: $enabled)
                ForEach(limits) { l in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(l.category.color).frame(width: 29, height: 29)
                            .overlay(Image(systemName: "hourglass").font(.caption).foregroundStyle(.white))
                        VStack(alignment: .leading) { Text(l.category.rawValue); Text(minutesLabel(l.minutes)).font(.footnote).foregroundStyle(.secondary) }
                    }
                }
                .onDelete { limits.remove(atOffsets: $0) }
                Button("Add Limit") { adding = true }
            } footer: { Text("Set daily time limits for app categories you want to manage. Limits reset every day at midnight.") }
        }
        .navigationTitle("App Limits")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $adding) { AddLimitSheet { limits.append(Limit(category: $0, minutes: $1)) } }
    }
}

private struct AddLimitSheet: View {
    var onAdd: (ScreenTimeCategory, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var category: ScreenTimeCategory = .social
    @State private var minutes = 60
    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(ScreenTimeCategory.allCases, id: \.self) { c in
                        HStack {
                            RoundedRectangle(cornerRadius: 6).fill(c.color).frame(width: 24, height: 24)
                            Text(c.rawValue); Spacer()
                            if c == category { Image(systemName: "checkmark").foregroundStyle(.tint) }
                        }
                        .contentShape(Rectangle()).onTapGesture { category = c }
                    }
                }
                Section("Time") { Stepper("\(minutesLabel(minutes))", value: $minutes, in: 15...480, step: 15) }
            }
            .navigationTitle("Choose Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Add") { onAdd(category, minutes); dismiss() } }
            }
        }
    }
}

struct AlwaysAllowedView: View {
    @State private var allowed: Set<String> = ["com.mock.pingme", "com.mock.wander"]
    var body: some View {
        List {
            Section("Allowed Apps") {
                ForEach(MockAppCatalog.all.filter { allowed.contains($0.bundleID) }) { app in
                    HStack(spacing: 12) {
                        Button { allowed.remove(app.bundleID) } label: { Image(systemName: "minus.circle.fill").foregroundStyle(.red) }.buttonStyle(.borderless)
                        AppIconView(app: app, side: 29); Text(app.name)
                    }
                }
            }
            Section("Choose Apps") {
                ForEach(MockAppCatalog.all.filter { !allowed.contains($0.bundleID) }) { app in
                    HStack(spacing: 12) {
                        Button { allowed.insert(app.bundleID) } label: { Image(systemName: "plus.circle.fill").foregroundStyle(.green) }.buttonStyle(.borderless)
                        AppIconView(app: app, side: 29); Text(app.name)
                    }
                }
            }
        }
        .navigationTitle("Always Allowed")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScreenDistanceView: View {
    @AppStorage("screenDistance") private var on = false
    var body: some View {
        List {
            Section { Toggle("Screen Distance", isOn: $on) } footer: {
                Text("Screen Distance uses the TrueDepth camera to encourage you to move your \(MockDevice.current.deviceTypeName) farther away after holding it closer than 12 inches for an extended period.")
            }
        }
        .navigationTitle("Screen Distance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Content & Privacy Restrictions behind the mock passcode.
struct ContentPrivacyGateView: View {
    @State private var unlocked = false
    @State private var showPasscode = true
    @AppStorage("cpr.enabled") private var enabled = false
    var body: some View {
        Group {
            if unlocked {
                List {
                    Section { Toggle("Content & Privacy Restrictions", isOn: $enabled) }
                    Section {
                        NavigationLink("iTunes & App Store Purchases") { ContentUnavailableView("Purchases", systemImage: "cart") }
                        NavigationLink("Allowed Apps & Features") { ContentUnavailableView("Allowed Apps", systemImage: "app") }
                        NavigationLink("Store, Web, Siri & Game Center Content") { ContentUnavailableView("Content", systemImage: "globe") }
                    }.disabled(!enabled)
                }
            } else {
                Color.clear
            }
        }
        .navigationTitle("Content & Privacy Restrictions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPasscode) { MockPasscodeSheet(title: "Enter Screen Time Passcode") { unlocked = $0 } }
    }
}
