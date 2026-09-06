import SwiftUI

/// A NavigationLink container with icon, title, subtitle, and status options.
///
/// - Parameters:
///   - title: The label of the link.
///   - routeKey: Optional string destination key for RouteRegistry (defaults to the value of `title`).
///   - icon: The icon bundle ID or UTI.
///   - subtitle: Optional text under the title.
///   - status: Optional status text to display on the opposite side of the title.
///   - badgeCount: Optional badge count integer number.
///   - destination: The destination view to push.
struct SLink<Destination: View>: View {
    var title: String
    var routeKey: String?
    var icon: String
    var subtitle: String
    var status: String
    var badgeCount: Int
    private let destinationBuilder: () -> Destination
    
    init(
        _ title: String,
        routeKey: String? = nil,
        icon: String = "",
        subtitle: String = "",
        status: String = "",
        badgeCount: Int = 0,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.routeKey = routeKey
        self.icon = icon
        self.subtitle = subtitle
        self.status = status
        self.badgeCount = badgeCount
        self.destinationBuilder = destination
    }
    
    init(
        _ title: String,
        routeKey: String? = nil,
        icon: String = "",
        subtitle: String = "",
        status: String = "",
        badgeCount: Int = 0,
        destination: Destination
    ) {
        self.init(
            title,
            routeKey: routeKey,
            icon: icon,
            subtitle: subtitle,
            status: status,
            badgeCount: badgeCount
        ) {
            destination
        }
    }
    
    var body: some View {
        NavigationLink(value: routeKey ?? title) {
            Label {
                LabeledContent {
                    if status == "location.fill" {
                        Image(systemName: status)
                    } else if !status.isEmpty {
                        Text(status)
                            .foregroundStyle(.placeholder)
                    }
                } label: {
                    Text(title)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                    }
                }
            } icon: {
                if !icon.isEmpty {
                    IconView(icon)
                }
            }
            .badge(badgeCount)
            .badgeProminence(.increased)
        }
        .onAppear {
            RouteRegistry.shared.register(routeKey ?? title) { destinationBuilder() }
        }
    }
}

/// A `NavigationLink` with a fully custom label that pushes a String route
/// through `RouteRegistry`, exactly like `SLink` does.
///
/// Use this instead of `NavigationLink { destination } label: { … }` anywhere
/// inside the app: the iPad detail `NavigationStack` is bound to a `[String]`
/// path, so only String routes are tracked (and reset when the sidebar
/// selection changes). View-based links get "stuck" in that column.
///
/// - Parameters:
///   - key: Unique route key. Prefix it with the owning screen to avoid clashes.
///   - destination: The destination view to push.
///   - label: The row content.
struct RouteLink<Label: View, Destination: View>: View {
    let key: String
    private let destinationBuilder: () -> Destination
    private let labelBuilder: () -> Label

    init(
        _ key: String,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.key = key
        self.destinationBuilder = destination
        self.labelBuilder = label
    }

    var body: some View {
        NavigationLink(value: key) {
            labelBuilder()
        }
        .onAppear {
            RouteRegistry.shared.register(key) { destinationBuilder() }
        }
    }
}

/// A plain button that pushes a destination — for accessories like ⓘ that
/// sit inside a row next to another tappable control, where a nested
/// `NavigationLink` would not work.
///
/// Regular-width iPad pushes a String route via `RouteRegistry` onto
/// `model.path`; iPhone / compact uses `navigationDestination(isPresented:)`.
struct PushButton<Label: View, Destination: View>: View {
    let key: String
    private let destinationBuilder: () -> Destination
    private let labelBuilder: () -> Label

    @Environment(PrimarySettingsListModel.self) private var model
    @State private var pushCompact = false

    init(
        _ key: String,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.key = key
        self.destinationBuilder = destination
        self.labelBuilder = label
    }

    var body: some View {
        Button {
            if UIDevice.iPhone || model.isCompact {
                pushCompact = true
            } else {
                RouteRegistry.shared.register(key) { destinationBuilder() }
                model.path.append(key)
            }
        } label: {
            labelBuilder()
        }
        .buttonStyle(.borderless)
        .navigationDestination(isPresented: $pushCompact) {
            destinationBuilder()
        }
    }
}

#Preview("ContentView") {
    ContentView()
        .environment(PrimarySettingsListModel())
}

#Preview("SLink Example") {
    NavigationStack {
        List {
            SLink("First") { EmptyView() }
            SLink("Second", status: "Second", destination: EmptyView())
            SLink("Third", icon: "com.apple.Preferences", subtitle: "Third", status: "Third") { EmptyView() }
        }
        .navigationDestination(for: String.self) { key in
            RouteRegistry.shared.view(for: key) ?? AnyView(Text("Unknown: \(key)"))
        }
    }
}
