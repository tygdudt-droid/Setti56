import SwiftUI

/// A `List` container that includes commonly used properties and adjustments.
///
/// ```swift
/// var body: some View {
///     CustomList(title: "My Title") {
///         Text("Hello, World!")
///     }
/// }
/// ```
///
/// - Parameter title: The String to use as the navigation title.
/// - Parameter topPadding: The optional Bool on whether to use default or reduced top padding.
/// - Parameter content: The Content to display in the container.
struct CustomList<Content: View>: View {
    var title = ""
    var topPadding = false
    @ViewBuilder let content: Content

    var body: some View {
        List {
            content
        }
        .listStyle(.insetGrouped)
        .navigationTitle(LocalizedStringKey(title))
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, topPadding ? 0 : -17.5)
        .settingsReadableWidth()
        .navigationDestination(for: String.self) { key in
            // Never push a nil/blank destination (black page) for unregistered routes.
            RouteRegistry.shared.view(for: key) ?? AnyView(
                ContentUnavailableView("Not Available", systemImage: "questionmark.circle")
            )
        }
    }
}

/// iPadOS Settings keeps detail content at a readable width (about 730pt)
/// centered in the column; whatever is left over becomes equal side margins
/// (roughly 52pt on an 11-inch iPad, about 135pt on a 13-inch one).
///
/// Implemented as plain horizontal padding on the List (the approach that
/// always worked here), with the amount measured from the column width.
struct SettingsReadableWidth: ViewModifier {
    /// Width of the cards on iPadOS 26 Settings, measured from screenshots.
    static let maxContentWidth: CGFloat = 730
    /// Built-in horizontal inset of an inset-grouped List on iPad.
    static let defaultListInset: CGFloat = 20
    /// Used until the first measurement arrives (11-inch iPad value).
    static let fallbackInset: CGFloat = 52

    @State private var inset: CGFloat = SettingsReadableWidth.fallbackInset

    func body(content: Content) -> some View {
        if UIDevice.iPad {
            content
                .padding(.horizontal, inset)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { width in
                    inset = Self.sideInset(for: width)
                }
        } else {
            content
        }
    }

    static func sideInset(for width: CGFloat) -> CGFloat {
        guard width > 0 else { return fallbackInset }
        return max(0, (width - maxContentWidth) / 2 - defaultListInset)
    }
}

extension View {
    /// Centers list content at the iPadOS Settings readable width. No-op on iPhone.
    func settingsReadableWidth() -> some View {
        modifier(SettingsReadableWidth())
    }
}

#Preview {
    NavigationStack {
        GeneralView()
    }
}
