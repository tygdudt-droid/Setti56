import SwiftUI

struct FolderExpandedView: View {
    let title: String
    let apps: [MockApp]
    @State private var appeared = false

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                    ForEach(Array(apps.enumerated()), id: \.element.id) { i, app in
                        VStack(spacing: 6) {
                            AppIconView(app: app, side: 62).contextMenu { AppContextMenu(app: app) }
                            Text(app.name).font(.caption).lineLimit(1)
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.7)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(i) * 0.04), value: appeared)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}
