import SwiftUI

struct AppleAccountSignInSheet: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    enum Step { case email, password, verifying, code }
    @State private var step: Step = .email
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var error: String?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "apple.logo").font(.system(size: 44)).padding(.top, 20)
                VStack(spacing: 6) {
                    Text(step == .email ? "Sign in with an Apple Account" : email)
                        .font(step == .email ? .title2.bold() : .headline)
                        .multilineTextAlignment(.center)
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                Group {
                    switch step {
                    case .email:
                        TextField("Email or Phone Number", text: $email)
                            .textContentType(.username).keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                            .focused($focused)
                            .padding(14).glassCard(cornerRadius: 12)
                    case .password:
                        SecureField("Password", text: $password)
                            .textContentType(.password).focused($focused)
                            .padding(14).glassCard(cornerRadius: 12)
                    case .verifying:
                        ProgressView("Signing In…").padding()
                    case .code:
                        VerificationCodeField(code: $code)
                    }
                }
                .padding(.horizontal)
                if let error { Text(error).foregroundStyle(.red).font(.footnote) }
                Spacer()
                Button(action: advance) {
                    Text("Continue").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .glassProminentButton()
                .disabled(!canContinue)
                .padding(.horizontal)
                Button("Forgot password or don’t have an account?") {}.font(.footnote).padding(.bottom, 8)
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .onAppear { focused = true }
        }
        .interactiveDismissDisabled(step == .verifying)
    }

    private var subtitle: String {
        switch step {
        case .email: return "Your Apple Account is used to access iCloud, the App Store, and more."
        case .password: return "Enter the password for your Apple Account."
        case .verifying: return ""
        case .code: return "A message with a verification code has been sent to your devices. Enter the code to continue."
        }
    }

    private var canContinue: Bool {
        switch step {
        case .email: return email.contains("@") || email.filter(\.isNumber).count >= 10
        case .password: return password.count >= 4
        case .code: return code.count == 6
        case .verifying: return false
        }
    }

    private func advance() {
        error = nil
        switch step {
        case .email:
            withAnimation { step = .password }
            focused = true
        case .password:
            withAnimation { step = .verifying }
            Task {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation { step = .code }
            }
        case .code:
            store.account = .from(email: email)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        case .verifying:
            break
        }
    }
}

struct VerificationCodeField: View {
    @Binding var code: String
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad).textContentType(.oneTimeCode)
                .focused($focused).opacity(0.01)
                .onChange(of: code) { _, v in code = String(v.filter(\.isNumber).prefix(6)) }
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { i in
                    let chars = Array(code)
                    Text(i < chars.count ? String(chars[i]) : " ")
                        .font(.title2.monospacedDigit())
                        .frame(width: 42, height: 52)
                        .glassCard(cornerRadius: 10)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .frame(height: 52)
        .onAppear { focused = true }
    }
}
