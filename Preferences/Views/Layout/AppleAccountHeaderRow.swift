//
//  AppleAccountHeaderRow.swift
//  Preferences
//
//  Root-list header row: signed-out shows the sign-in entry, signed-in
//  shows the account name/avatar and pushes the account page.
//

import SwiftUI

struct AppleAccountHeaderRow: View {
    @Environment(PrimarySettingsListModel.self) private var model
    @Environment(SettingsStore.self) private var store
    @State private var showingSignInError = false
    @State private var showingSignInSheet = false

    var body: some View {
        if let account = store.account {
            NavigationLink {
                AppleAccountView()
            } label: {
                HStack(spacing: 14) {
                    AvatarView(account: account, size: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.fullName)
                            .font(.title2)
                        Text("Apple Account, iCloud, and more")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        } else {
            Button {
                if model.isConnected {
                    showingSignInSheet.toggle()
                } else {
                    SettingsLogger.info("Presenting Network Alert.")
                    showingSignInError.toggle()
                }
            } label: {
                AppleAccountSection()
            }
            .alert("Connect to the Internet to sign in to your device.", isPresented: $showingSignInError) {
                Button("OK") {}
            }
            .sheet(isPresented: $showingSignInSheet) {
                NavigationStack {
                    SelectSignInOptionView()
                        .interactiveDismissDisabled()
                }
            }
        }
    }
}

#Preview {
    List {
        Section {
            AppleAccountHeaderRow()
        }
    }
    .environment(PrimarySettingsListModel())
    .environment(SettingsStore.shared)
}
