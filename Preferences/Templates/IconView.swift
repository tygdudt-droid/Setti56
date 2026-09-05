import SwiftUI

/// An `Image` view of an icon based on its UTI or bundle ID.
///
/// ```swift
/// IconView("com.example.app") // Example Bundle ID
/// IconView("com.example.graphic-icon.name") // Example UTI
/// ```
///
/// - Parameter icon: The `String` identifier of the image asset as a UTI or bundle ID.
///
/// - Note: If no bundle ID matches, it will return a template icon.
///
/// - Note: If no UTI matches, it will return a question mark on a doc icon.
///
/// - Warning: This view makes use of private methods. It is not recommended for public use.
struct IconView: View {
    let icon: String
    private var knownUTIPrefix: Bool {
        let lower = icon.lowercased()
        
        return icon.hasPrefix("com.apple.graphic")
            || lower.hasPrefix("com.apple.a")
            || lower.hasPrefix("com.apple.screen-time")
            || (icon.hasPrefix("com.apple.gamecenter") && !UIDevice.IsSimulated)
    }
    
    init(_ icon: String = "") {
        self.icon = icon
    }
    
    /// Known Settings graphics that may fail the private-framework lookup —
    /// mapped to their real SF Symbol counterparts.
    private var fallbackSymbol: String? {
        switch icon {
        case "com.apple.graphic-icon.airdrop": return "dot.radiowaves.left.and.right"
        case "com.apple.graphic-icon.wifi": return "wifi"
        case "com.apple.graphic-icon.bluetooth": return "bluetooth"
        case "com.apple.graphic-icon.gear": return "gearshape"
        case "com.apple.graphic-icon.vpn": return "globe"
        case "com.apple.graphic-icon.battery": return "battery.100"
        case "com.apple.graphic-icon.cellular-settings": return "antenna.radiowaves.left.and.right"
        case "com.apple.graphic-icon.airplane-mode": return "airplane"
        case "com.apple.graphic-icon.privacy": return "hand.raised.fill"
        case "com.apple.graphic-icon.notifications": return "bell.fill"
        case "com.apple.graphic-icon.focus": return "moon.fill"
        case "com.apple.graphic-icon.screen-time": return "hourglass"
        case "com.apple.graphic-icon.display": return "sun.max"
        case "com.apple.graphic-icon.camera": return "camera.fill"
        case "com.apple.graphic-icon.accessibility": return "accessibility"
        case "com.apple.graphic-icon.search": return "magnifyingglass"
        case "com.apple.graphic-icon.wallpaper": return "photo"
        default: return nil
        }
    }

    var body: some View {
        if knownUTIPrefix, let graphicIcon = UIImage.icon(forUTI: icon) {
            Image(uiImage: graphicIcon)
        } else if !knownUTIPrefix, let asset = UIImage.icon(forBundleID: icon) {
            Image(uiImage: asset)
        } else if let symbol = fallbackSymbol {
            // Settings-style tinted glyph for known icons.
            ZStack {
                RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                    .fill(LinearGradient(colors: [Color(.systemBlue).opacity(0.85), Color(.systemBlue)],
                                         startPoint: .top, endPoint: .bottom))
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 29, height: 29)
        } else {
            // Generic placeholder so rows never render without an icon.
            ZStack {
                RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                    .fill(Color(.systemGray4))
                Image(systemName: "app.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 29, height: 29)
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    ContentView()
        .environment(PrimarySettingsListModel())
}
