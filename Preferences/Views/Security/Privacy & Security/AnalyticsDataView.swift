import SwiftUI

/// Settings > Privacy & Security > Analytics & Improvements > Analytics Data
/// Matches iOS: a plain file list (searchable) where each file opens a
/// monospaced viewer with its own Share button. Long-press a row for quick Share.
///
/// Rows push a String route through `RouteRegistry` (like every other link in
/// the app) so they work both on iPhone and inside the iPad detail
/// `NavigationStack`, whose path is bound to `[String]` and cannot present
/// values of any other type.
struct AnalyticsDataView: View {
    @State private var store = AnalyticsStore.shared
    @State private var searchText = ""

    private var files: [AnalyticsFile] {
        guard !searchText.isEmpty else { return store.files }
        return store.files.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        CustomList(title: "Analytics Data", topPadding: true) {
            Section {
                ForEach(files) { file in
                    RouteLink(Self.routeKey(for: file)) {
                        AnalyticsFileDetailView(file: file)
                    } label: {
                        Text(file.name)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .contextMenu {
                        ShareLink(item: file.url, preview: SharePreview(file.name, image: Image(systemName: "doc.text")))
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            try? FileManager.default.removeItem(at: file.url)
                            store.reload()
                        }
                    }
                }
            }
        }
        .task { store.refresh() }
        .refreshable { store.refresh() }
        .searchable(
            text: $searchText,
            placement: UIDevice.iPhone ? .automatic : .toolbar,
            prompt: "Search"
        )
        .overlay {
            if store.files.isEmpty {
                ContentUnavailableView("No Analytics Data", systemImage: "doc.text")
            }
        }
    }

    static func routeKey(for file: AnalyticsFile) -> String {
        "AnalyticsData/\(file.name)"
    }
}

/// Settings > … > Analytics Data > [file]
/// iOS shows the file name as an inline title, the raw contents in a small
/// monospaced font (wrapped, vertical scrolling only) and a Share button.
struct AnalyticsFileDetailView: View {
    let file: AnalyticsFile
    @State private var text = ""

    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, UIDevice.iPad ? 8 : 12)
                .padding(.top, 6)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: file.url, preview: SharePreview(file.name, image: Image(systemName: "doc.text")))
            }
        }
        .task { text = AnalyticsStore.shared.contents(of: file) }
    }
}

#Preview {
    NavigationStack {
        AnalyticsDataView()
    }
}
