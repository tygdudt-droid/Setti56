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

/// Settings > Apps > Hidden Apps and General > [Device] Storage > Hidden Apps.
///
/// Authentication happens in `HiddenAppsRow` *before* this page is pushed
/// (iOS shows the Face ID / Touch ID prompt over the previous list and does
/// nothing on cancel), so this view only renders content.
///
/// Two appearances, both matching iOS 26 on iPad:
/// - cardStyle (Storage): inline "Hidden Apps" title, a trailing "Size ⇅"
///   sort menu above a grouped card holding the app rows (name + size) or
///   the empty state.
/// - plain (Apps): no title; app rows (name + chevron) in a grouped card, or
///   the empty state centered in the whole page.
struct HiddenAppsView: View {
    @Environment(SettingsStore.self) private var store
    var cardStyle = true
    @State private var sort: HiddenAppsSort = .size

    private var hidden: [MockApp] {
        let apps = MockAppCatalog.all.filter { store.hiddenAppBundleIDs.contains($0.bundleID) }
        switch sort {
        case .size: return apps.sorted { mockSize($0) > mockSize($1) }
        case .name: return apps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }
    }

    var body: some View {
        if cardStyle {
            cardContent
        } else {
            plainContent
        }
    }

    // MARK: Card style (Storage)
    private var cardContent: some View {
        CustomList(title: "Hidden Apps", topPadding: true) {
            Section {
                if hidden.isEmpty {
                    HiddenAppsEmptyState(showsDescription: true)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                        .padding(.bottom, 56)
                } else {
                    ForEach(hidden) { app in
                        RouteLink("HiddenApps/card/\(app.bundleID)") {
                            hiddenAppDetail(app)
                        } label: {
                            HStack(spacing: 12) {
                                AppIconView(app: app, side: 29)
                                Text(app.name)
                                Spacer()
                                Text(MockStorageCatalog.format(mockSize(app)))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Spacer()
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(HiddenAppsSort.allCases, id: \.self) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sort.title)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.body)
                        .foregroundStyle(.blue)
                    }
                }
                .textCase(nil)
            }
        }
    }

    // MARK: Plain style (Apps)
    @ViewBuilder
    private var plainContent: some View {
        if hidden.isEmpty {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()
                HiddenAppsEmptyState(showsDescription: false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            CustomList(title: "", topPadding: true) {
                Section {
                    ForEach(hidden) { app in
                        RouteLink("HiddenApps/plain/\(app.bundleID)") {
                            hiddenAppDetail(app)
                        } label: {
                            HStack(spacing: 12) {
                                AppIconView(app: app, side: 29)
                                Text(app.name)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Simple per-app page with an Unhide action.
    private func hiddenAppDetail(_ app: MockApp) -> some View {
        CustomList(title: app.name, topPadding: true) {
            Section {
                HStack(spacing: 14) {
                    AppIconView(app: app, side: 60)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name).font(.title3.weight(.semibold))
                        Text(MockStorageCatalog.format(mockSize(app))).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                Button("Unhide App") { unhideMockApp(app, in: store) }
            } footer: {
                Text("The app will appear again on the Home Screen and in the App Library.")
            }
        }
    }

    /// Stable mock size per app (40 MB – 940 MB) derived from the bundle ID.
    private func mockSize(_ app: MockApp) -> Int64 {
        let h = app.bundleID.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFF }
        return MockStorageCatalog.mb(Double(40 + h % 900))
    }
}

enum HiddenAppsSort: CaseIterable {
    case size, name

    var title: String {
        switch self {
        case .size: return "Size"
        case .name: return "Name"
        }
    }
}

/// Large centered placeholder used by both Hidden Apps appearances.
struct HiddenAppsEmptyState: View {
    var showsDescription: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 54, weight: .regular))
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            Text("No Hidden Apps")
                .font(.title.weight(.bold))
            if showsDescription {
                Text("No hidden apps found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
        }
        .multilineTextAlignment(.center)
    }
}

/// List row that opens Hidden Apps the way iOS does: Face ID / Touch ID /
/// passcode first, over the current list, and only then push the page.
/// Cancelling leaves you where you were.
///
/// - Regular-width iPad: the detail stack is bound to `model.path`, so the
///   page is pushed as a String route through `RouteRegistry`.
/// - iPhone / compact: pushed with `navigationDestination(isPresented:)`.
struct HiddenAppsRow<RowLabel: View>: View {
    var cardStyle: Bool
    @ViewBuilder var label: () -> RowLabel

    @Environment(SettingsStore.self) private var store
    @Environment(PrimarySettingsListModel.self) private var model
    @State private var authenticating = false
    @State private var pushCompact = false
    @State private var showPasscode = false
    @State private var passcodeAccepted = false

    private var routeKey: String { cardStyle ? "HiddenApps/card" : "HiddenApps/plain" }

    var body: some View {
        Button {
            Task { await tap() }
        } label: {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .navigationDestination(isPresented: $pushCompact) {
            HiddenAppsView(cardStyle: cardStyle)
        }
        .sheet(
            isPresented: $showPasscode,
            onDismiss: {
                if passcodeAccepted { push() }
            },
            content: {
                MockPasscodeSheet(title: "Enter Passcode to View Hidden Apps") { ok in
                    passcodeAccepted = ok
                    showPasscode = false
                }
            }
        )
    }

    private func tap() async {
        guard !authenticating else { return }
        guard store.requireAuthForHiddenApps else { push(); return }
        authenticating = true
        defer { authenticating = false }
        switch await HiddenAppsAuth.authenticate(reason: "Unlock Hidden Apps") {
        case .some(true):
            push()
        case .some(false):
            // Cancelled or failed: iOS simply stays on the current list.
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .none:
            // No biometrics / device passcode (Simulator): mock passcode sheet.
            if store.mockPasscode.isEmpty { push() } else { showPasscode = true }
        }
    }

    private func push() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        if UIDevice.iPhone || model.isCompact {
            pushCompact = true
        } else {
            RouteRegistry.shared.register(routeKey) { HiddenAppsView(cardStyle: cardStyle) }
            model.path.append(routeKey)
        }
    }
}
