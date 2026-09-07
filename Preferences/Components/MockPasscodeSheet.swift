import SwiftUI
import UIKit

// MARK: - Screen-capture protection

/// Hides its content from screen recordings, screenshots and AirPlay or
/// SharePlay mirroring, the way the real passcode screen does. The content
/// stays fully visible on the device itself.
///
/// It reuses the drawing canvas of a secure `UITextField`: iOS leaves that
/// layer out of any capture pipeline. If the internal view is unavailable
/// the content is simply shown unprotected rather than disappearing.
///
/// - Warning: This relies on a private view hierarchy, like other parts of
///   this project. Do not reuse it in a shipping app.
struct CaptureProtected<Content: View>: UIViewControllerRepresentable {
    @ViewBuilder let content: Content

    func makeUIViewController(context: Context) -> CaptureProtectedController<Content> {
        CaptureProtectedController(rootView: content)
    }

    func updateUIViewController(_ controller: CaptureProtectedController<Content>, context: Context) {
        controller.update(content)
    }
}

final class CaptureProtectedController<Content: View>: UIViewController {
    private let host: UIHostingController<Content>
    /// Held so the canvas view it owns is not torn down.
    private let secureField = UITextField()

    init(rootView: Content) {
        host = UIHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func update(_ rootView: Content) {
        host.rootView = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(host)
        let container = secureCanvas() ?? UIView()
        container.subviews.forEach { $0.removeFromSuperview() }
        container.isUserInteractionEnabled = true
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)
        container.addSubview(host.view)
        host.didMove(toParent: self)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    /// The secure field's canvas view, which iOS omits from screen capture.
    private func secureCanvas() -> UIView? {
        secureField.isSecureTextEntry = true
        if let canvas = secureField.layer.sublayers?.first?.delegate as? UIView {
            return canvas
        }
        return secureField.subviews.first
    }
}

extension View {
    /// Keeps this view out of screen recordings and screenshots.
    func hiddenFromScreenCapture() -> some View {
        CaptureProtected { self }
    }
}

// MARK: - Passcode sheets

/// Lock-screen style 6-digit passcode entry with its own keypad.
/// Everything on screen is hidden from recordings and screen sharing.
struct MockPasscodeSheet: View {
    var title = "Enter Passcode"
    var onResult: (Bool) -> Void

    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var entered = ""
    @State private var shake = 0

    private let keys: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    var body: some View {
        CaptureProtected {
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
        }
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

/// iPadOS/iOS 26 style passcode prompt: centered form sheet with a close
/// button, blue lock, "Enter your passcode", six dots and the system number
/// pad. Drag down or ✕ cancels.
///
/// The lock, title and dots sit inside a `CaptureProtected` container and a
/// secure text field owns the keyboard, so a recording or shared screen
/// never shows the entry in progress.
struct PasscodeEntrySheet: View {
    var title = "Enter your passcode"
    var subtitle: String
    var onResult: (Bool) -> Void

    @Environment(SettingsStore.self) private var store
    @State private var entered = ""
    @State private var shake = 0
    @State private var checking = false
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            CaptureProtected {
                sheetContent
            }

            // Invisible secure field that owns the keyboard: iOS treats the
            // input as a password, so nothing is echoed or predicted.
            SecureField("", text: $entered)
                .keyboardType(.numberPad)
                .textContentType(.password)
                .focused($focused)
                .frame(width: 1, height: 1)
                .opacity(0.02)
                .accessibilityHidden(true)
        }
        .presentationBackground(Color(uiColor: .secondarySystemBackground))
        .presentationCornerRadius(38)
        .presentationSizing(.form)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { focused = true }
        }
        .onChange(of: entered) { _, value in
            let digits = String(value.filter(\.isNumber).prefix(6))
            if digits != value { entered = digits; return }
            if digits.count == 6 && !checking { check(digits) }
        }
    }

    private var sheetContent: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Image(systemName: "lock")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.blue)
                    .padding(.top, 84)
                Text(title)
                    .font(.title2.weight(.bold))
                    .padding(.top, 40)
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)
                    .padding(.horizontal, 32)
                dots
                    .padding(.top, 44)
                    .modifier(ShakeEffect(shakes: shake))
                    .contentShape(Rectangle())
                    .onTapGesture { focused = true }
                Spacer()
            }
            .frame(maxWidth: .infinity)

            Button {
                onResult(false)
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(.plain)
            .padding(16)
        }
    }

    private var dots: some View {
        HStack(spacing: 20) {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .strokeBorder(.primary, lineWidth: 1.5)
                    .background(Circle().fill(i < entered.count ? Color.primary : .clear))
                    .frame(width: 20, height: 20)
            }
        }
    }

    private func check(_ code: String) {
        checking = true
        if code == store.mockPasscode {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onResult(true)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            withAnimation(.default) { shake += 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                entered = ""
                checking = false
            }
        }
    }
}
