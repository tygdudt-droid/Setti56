import SwiftUI

/// Settings > Privacy & Security > Analytics & Improvements > Analytics Data
/// Matches iOS: a plain file list (searchable) where each file opens a
/// monospaced viewer with its own Share button. Long-press a row for quick Share.
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
                    NavigationLink(value: file) {
                        Text(file.name).font(.footnote).lineLimit(1).truncationMode(.middle)
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
        .navigationDestination(for: AnalyticsFile.self) { AnalyticsFileDetailView(file: $0) }
        .refreshable { store.reload() }
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
}

struct AnalyticsFileDetailView: View {
    let file: AnalyticsFile
    @State private var text = ""

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .textSelection(.enabled)
                .padding(.horizontal, UIDevice.iPad ? 20 : 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
