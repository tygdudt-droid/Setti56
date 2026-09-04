import SwiftUI

/// iOS 26 Liquid Glass with graceful fallback for older SDK/OS.
extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    @ViewBuilder
    func glassProminentButton() -> some View {
        if #available(iOS 26.0, *) { self.buttonStyle(.glassProminent) } else { self.buttonStyle(.borderedProminent) }
    }

    @ViewBuilder
    func glassButton() -> some View {
        if #available(iOS 26.0, *) { self.buttonStyle(.glass) } else { self.buttonStyle(.bordered) }
    }
}
