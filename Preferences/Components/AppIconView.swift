import SwiftUI

/// Apple-style squircle icon (continuous corners, 22.37% radius).
struct AppIconView: View {
    let app: MockApp
    var side: CGFloat = 60

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: side * 0.2237, style: .continuous)
                .fill(LinearGradient(colors: [app.tint.opacity(0.82), app.tint],
                                     startPoint: .top, endPoint: .bottom))
            Image(systemName: app.icon)
                .font(.system(size: side * 0.46, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: side, height: side)
        .accessibilityLabel(app.name)
    }
}
