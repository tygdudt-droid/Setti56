import SwiftUI

/// Add `NavigationLink("App Library") { AppLibraryView() }` to HomeScreenView.
struct AppLibraryView: View {
    @Environment(SettingsStore.self) private var store
    @State private var query = ""
    @Namespace private var ns

    private var categories: [AppLibraryCategory] {
        AppLibraryCategory.allCases.filter { !MockAppCatalog.apps(in: $0, excluding: store.hiddenAppBundleIDs).isEmpty }
    }
    private var searchResults: [MockApp] {
        MockAppCatalog.all
            .filter { !store.hiddenAppBundleIDs.contains($0.bundleID) }
            .filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.16, green: 0.24, blue: 0.48), Color(red: 0.55, green: 0.32, blue: 0.62)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if query.isEmpty { folderGrid } else { alphabeticalList }
        }
        .navigationTitle("App Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "App Library")
    }

    private var folderGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 22) {
                ForEach(categories, id: \.self) { cat in
                    CategoryFolderTile(category: cat, apps: MockAppCatalog.apps(in: cat, excluding: store.hiddenAppBundleIDs), namespace: ns)
                }
                HiddenFolderTile(namespace: ns)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private var alphabeticalList: some View {
        let grouped = Dictionary(grouping: searchResults) { String($0.name.prefix(1)).uppercased() }
        return ScrollViewReader { proxy in
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { letter in
                    Section(letter) {
                        ForEach(grouped[letter] ?? []) { app in
                            HStack(spacing: 12) { AppIconView(app: app, side: 36); Text(app.name) }
                        }
                    }
                    .id(letter)
                }
            }
            .scrollContentBackground(.hidden)
            .overlay(alignment: .trailing) {
                VStack(spacing: 2) {
                    ForEach(grouped.keys.sorted(), id: \.self) { l in
                        Text(l).font(.caption2.bold()).foregroundStyle(.white)
                            .onTapGesture { withAnimation { proxy.scrollTo(l, anchor: .top) } }
                    }
                }
                .padding(.trailing, 4)
            }
        }
    }
}
