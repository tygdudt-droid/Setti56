import SwiftUI

/// Lock-screen style 6-digit passcode entry.
struct MockPasscodeSheet: View {
    var title = "Enter Passcode"
    var onResult: (Bool) -> Void

    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var entered = ""
    @State private var shake = 0

    private let keys: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)
            Image(systemName: "lock.fill").font(.title2).foregroundStyle(.secondary)
            Text(title).font(.title3.weight(.semibold))
            HStack(spacing: 18) {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .strokeBorder(.primary, lineWidth: 1.2)
                        .background(Circle().fill(i < entered.count ? Color.primary : .clear))
                        .frame(width: 13, height: 13)
                }
            }
            .modifier(ShakeEffect(shakes: shake))
            Spacer()
            VStack(spacing: 16) {
                ForEach(keys, id: \.self) { row in
                    HStack(spacing: 24) {
                        ForEach(row, id: \.self) { key in
                            Button { tap(key) } label: {
                                Text(key).font(.system(size: 30, weight: .regular))
                                    .frame(width: 78, height: 78)
                                    .background(Circle().fill(key.isEmpty ? .clear : Color.primary.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                            .disabled(key.isEmpty)
                        }
                    }
                }
            }
            Button("Cancel") { dismiss(); onResult(false) }
                .padding(.bottom, 24)
        }
        .padding()
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }

    private func tap(_ key: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if key == "⌫" { if !entered.isEmpty { entered.removeLast() }; return }
        guard entered.count < 6 else { return }
        entered.append(key)
        if entered.count == 6 {
            if entered == store.mockPasscode {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss(); onResult(true)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                withAnimation(.default) { shake += 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { entered = "" }
            }
        }
    }
}
