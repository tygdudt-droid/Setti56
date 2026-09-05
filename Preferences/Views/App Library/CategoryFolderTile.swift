import SwiftUI

struct CategoryFolderTile: View {
    let category: AppLibraryCategory
    let apps: [MockApp]
    let namespace: Namespace.ID
    @State private var expanded = false

    private var showsFourLarge: Bool { category == .suggestions || category == .recentlyAdded || apps.count <= 4 }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous).fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 0.5))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    if showsFourLarge {
                        ForEach(apps.prefix(4)) { app in
                            AppIconView(app: app, side: 60).contextMenu { AppContextMenu(app: app) }
                        }
                    } else {
                        ForEach(apps.prefix(3)) { app in
                            AppIconView(app: app, side: 60).contextMenu { AppContextMenu(app: app) }
                        }
                        MiniCluster(apps: Array(apps.dropFirst(3)))
                    }
                }
                .padding(18)
            }
            .frame(width: 168, height: 168)
            .matchedTransitionSourceCompat(id: category.rawValue, in: namespace)
            .onTapGesture { expanded = true }
            Text(category.rawValue).font(.footnote).foregroundStyle(.white).lineLimit(1)
        }
        .navigationDestination(isPresented: $expanded) {
            FolderExpandedView(title: category.rawValue, apps: apps)
                .zoomTransitionCompat(sourceID: category.rawValue, in: namespace)
        }
    }
}

struct MiniCluster: View {
    let apps: [MockApp]
    var body: some View {
        let cols = apps.count > 4 ? 3 : 2
        let side: CGFloat = cols == 3 ? 15 : 24
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(.white.opacity(0.18))
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(side), spacing: 4), count: cols), spacing: 4) {
                ForEach(apps.prefix(cols * cols)) { AppIconView(app: $0, side: side) }
            }
        }
        .frame(width: 60, height: 60)
    }
}

struct AppContextMenu: View {
    let app: MockApp
    @Environment(SettingsStore.self) private var store
    var isHidden: Bool { store.hiddenAppBundleIDs.contains(app.bundleID) }
    var body: some View {
        Button("Add to Home Screen", systemImage: "plus.square.on.square") {}
        Button("Share App", systemImage: "square.and.arrow.up") {}
        Button(isHidden ? "Don’t Require Face ID" : "Require Face ID", systemImage: "faceid") {
            toggleHidden(app, in: store, isHidden: isHidden)
        }
        Button("Delete App", systemImage: "trash", role: .destructive) {}
    }
}

@MainActor
private func toggleHidden(_ app: MockApp, in store: SettingsStore, isHidden: Bool) {
    withAnimation(.spring()) {
        if isHidden {
            _ = store.hiddenAppBundleIDs.remove(app.bundleID)
        } else {
            _ = store.hiddenAppBundleIDs.insert(app.bundleID)
        }
    }
}

extension View {
    @ViewBuilder
    func matchedTransitionSourceCompat(id: String, in ns: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) { self.matchedTransitionSource(id: id, in: ns) } else { self }
    }
    @ViewBuilder
    func zoomTransitionCompat(sourceID: String, in ns: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) { self.navigationTransition(.zoom(sourceID: sourceID, in: ns)) } else { self }
    }
}
