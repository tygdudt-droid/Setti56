import SwiftUI

/// Simple signed-in/signed-out row (used inside compact lists).
struct AppleAccountRow: View {
    @Environment(SettingsStore.self) private var store
    @State private var showSignIn = false

    var body: some View {
        if let account = store.account {
            NavigationLink { AppleAccountView() } label: {
                HStack(spacing: 14) {
                    AvatarView(account: account, size: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.fullName).font(.title2)
                        Text("Apple Account, iCloud, and more").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        } else {
            Button { showSignIn = true } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56)).foregroundStyle(.gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sign in to your \(MockDevice.current.deviceTypeName)")
                            .font(.title3).foregroundStyle(.primary)
                        Text("Set up iCloud, the App Store, and more.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.footnote.bold()).foregroundStyle(.tertiary)
                }
                .padding(.vertical, 6)
            }
            .sheet(isPresented: $showSignIn) { AppleAccountSignInSheet() }
        }
    }
}

#Preview {
    List {
        AppleAccountRow()
    }
    .environment(SettingsStore.shared)
}
