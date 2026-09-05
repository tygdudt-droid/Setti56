import SwiftUI

struct AnalyticsDataView: View {
    @State private var store = AnalyticsStore.shared
    @State private var confirmDelete = false

    var body: some View {
        List(store.files) { file in
            NavigationLink(value: file) {
                Text(file.name).font(.footnote).lineLimit(1).truncationMode(.middle)
            }
        }
        .navigationTitle("Analytics Data")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AnalyticsFile.self) { AnalyticsFileDetailView(file: $0) }
        .refreshable { store.reload() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink("Share All…", items: store.files.map(\.url))
                    Button("Delete All", systemImage: "trash", role: .destructive) { confirmDelete = true }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .confirmationDialog("Delete all analytics data?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) { store.deleteAll() }
        }
        .overlay { if store.files.isEmpty { ContentUnavailableView("No Analytics Data", systemImage: "doc.text") } }
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
                .padding()
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
