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
                ContentUnavailableView("No Hidden Apps", systemImage: "eye.slash", description: Text("Touch and hold an app and choose Require Face ID to hide it."))
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                    ForEach(Array(apps.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 6) {
                            AppIconView(app: app, side: 62)
                                .contextMenu {
                                    Button("Unhide", systemImage: "eye") { withAnimation(.spring) { store.hiddenAppBundleIDs.remove(app.bundleID) } }
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
