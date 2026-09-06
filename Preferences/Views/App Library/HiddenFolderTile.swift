import SwiftUI

/// Bottom-of-library Hidden folder: Face ID / passcode gate + de-blur reveal animation.
struct HiddenFolderTile: View {
    let namespace: Namespace.ID
    @Environment(SettingsStore.self) private var store
    @State private var unlocked = false
    @State private var expanded = false
    @State private var showPasscode = false
    @State private var shake = 0

    private var hidden: [MockApp] { MockAppCatalog.all.filter { store.hiddenAppBundleIDs.contains($0.bundleID) } }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous).fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 0.5))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(hidden.prefix(4)) { app in
                        AppIconView(app: app, side: 60)
                            .blur(radius: unlocked ? 0 : 14)
                            .saturation(unlocked ? 1 : 0)
                            .scaleEffect(unlocked ? 1 : 0.92)
                    }
                }
                .padding(18)
                Image(systemName: "eye.slash.fill")
                    .font(.title).foregroundStyle(.white.opacity(0.9))
                    .opacity(unlocked ? 0 : 1)
                    .scaleEffect(unlocked ? 1.6 : 1)
            }
            .frame(width: 168, height: 168)
            .matchedTransitionSourceCompat(id: "hidden", in: namespace)
            .modifier(ShakeEffect(shakes: shake))
            .onTapGesture { Task { await unlock() } }
            Text("Hidden").font(.footnote).foregroundStyle(.white)
        }
        .navigationDestination(isPresented: $expanded) {
            HiddenFolderExpandedView(apps: hidden)
                .zoomTransitionCompat(sourceID: "hidden", in: namespace)
        }
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                showPasscode = false
                if ok { reveal() } else { fail() }
            }
        }
        .onChange(of: expanded) { _, isExpanded in
            if !isExpanded { withAnimation(.easeOut(duration: 0.3)) { unlocked = false } }   // re-lock on return
        }
    }

    private func unlock() async {
        guard store.requireAuthForHiddenApps else { reveal(); return }
        switch await HiddenAppsAuth.authenticate() {
        case .some(true): reveal()
        case .some(false): fail()
        case .none: showPasscode = true
        }
    }

    private func reveal() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) { unlocked = true }   // phase 1: de-blur
        Task {
            try? await Task.sleep(for: .milliseconds(420))
            withAnimation(.smooth(duration: 0.35)) { expanded = true }                      // phase 2: zoom in
        }
    }

    private func fail() {
        withAnimation(.default) { shake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

struct HiddenFolderExpandedView: View {
    let apps: [MockApp]
    @Environment(SettingsStore.self) private var store
    @State private var appeared = false

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            if apps.isEmpty {
                ContentUnavailableView {
                    Label("No Hidden Apps", systemImage: "eye.slash")
                } description: {
                    Text("Touch and hold an app and choose Require Face ID to hide it.")
                }
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                    ForEach(Array(apps.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 6) {
                            AppIconView(app: app, side: 62)
                                .contextMenu {
                                    Button("Unhide", systemImage: "eye") { unhideMockApp(app, in: store) }
                                }
                            Text(app.name).font(.caption).lineLimit(1)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.7)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(i) * 0.05), value: appeared)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Hidden")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}

/// Shared helper so the unhide action stays easy for the type-checker.
@MainActor
private func unhideMockApp(_ app: MockApp, in store: SettingsStore) {
    withAnimation(.spring()) {
        _ = store.hiddenAppBundleIDs.remove(app.bundleID)
    }
}

/// Drop this Section into FaceIDPasscodeView ("Use Face ID For").
struct HiddenAppsSettingsSection: View {
    @Environment(SettingsStore.self) private var store
    @State private var showChange = false
    var body: some View {
        @Bindable var store = store
        Section {
            Toggle("Hidden Apps", isOn: $store.requireAuthForHiddenApps)
            Button("Change Mock Passcode") { showChange = true }
        } footer: {
            Text("Require Face ID or your passcode to reveal apps in the Hidden folder of the App Library. Current mock passcode: \(store.mockPasscode)")
        }
        .alert("New Passcode", isPresented: $showChange) {
            TextField("6 digits", text: $store.mockPasscode).keyboardType(.numberPad)
            Button("Done") { store.mockPasscode = String(store.mockPasscode.filter(\.isNumber).prefix(6)) }
        }
    }
}

/// Settings > Apps > Hidden Apps — Face ID / passcode gate first; nothing is
/// shown until the gate passes. Two appearances:
/// - cardStyle (from App Storage): rounded card + "Size ⇅" sort toolbar
/// - plain (from Apps): centered empty state / grid on a plain background
struct HiddenAppsView: View {
    @Environment(SettingsStore.self) private var store
    var cardStyle = true
    @State private var unlocked = false
    @State private var showPasscode = false
    @State private var shake = 0
    @State private var gateChecked = false
    @State private var sortByName = false

    private var hidden: [MockApp] {
        guard unlocked else { return [] }
        return MockAppCatalog.all.filter { store.hiddenAppBundleIDs.contains($0.bundleID) }
    }

    private var sortedHidden: [MockApp] {
        sortByName ? hidden.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } : hidden
    }

    var body: some View {
        if cardStyle {
            cardBody
        } else {
            plainBody
        }
    }

    // MARK: Card style (App Storage)
    private var cardBody: some View {
        CustomList(title: "Hidden Apps", topPadding: true) {
            Section {
                if sortedHidden.isEmpty {
                    ContentUnavailableView {
                        Label("No Hidden Apps", systemImage: "square.stack.3d.up.slash")
                    } description: {
                        Text("No hidden apps found.")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 64)
                } else {
                    grid
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { sortByName.toggle() } label: {
                    Label("Size", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .modifier(ShakeEffect(shakes: shake))
        .task { await gate() }
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                showPasscode = false
                if ok { reveal() } else { fail() }
            }
        }
    }

    // MARK: Plain style (Apps)
    private var plainBody: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if sortedHidden.isEmpty {
                ContentUnavailableView("No Hidden Apps", systemImage: "square.stack.3d.up.slash")
            } else {
                ScrollView {
                    grid
                        .padding(24)
                }
            }
        }
        .navigationTitle("Hidden Apps")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(ShakeEffect(shakes: shake))
        .task { await gate() }
        .sheet(isPresented: $showPasscode) {
            MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                showPasscode = false
                if ok { reveal() } else { fail() }
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
            ForEach(Array(sortedHidden.enumerated()), id: \.element.id) { i, app in
                VStack(spacing: 6) {
                    AppIconView(app: app, side: 60)
                        .contextMenu {
                            Button("Unhide", systemImage: "eye") { unhideMockApp(app, in: store) }
                        }
                    Text(app.name).font(.caption).lineLimit(1)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: unlocked)
    }

    private func gate() async {
        guard store.requireAuthForHiddenApps else { reveal(); return }
        switch await HiddenAppsAuth.authenticate(reason: "Unlock Hidden Apps") {
        case .some(true): reveal()
        case .some(false):
            if store.mockPasscode.isEmpty { fail() } else { showPasscode = true }
        case .none:
            if store.mockPasscode.isEmpty { fail() } else { showPasscode = true }
        }
    }

    private func reveal() {
        gateChecked = true
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) { unlocked = true }
    }

    private func fail() {
        gateChecked = true
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation(.default) { shake += 1 }
    }
}
