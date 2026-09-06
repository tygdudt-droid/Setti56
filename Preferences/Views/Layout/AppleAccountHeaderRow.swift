//
//  AppleAccountHeaderRow.swift
//  Preferences
//
//  Root-list header row: signed-out shows the sign-in entry, signed-in
//  shows the account name/avatar and opens the account page.
//
//  On iPhone (or a compact iPad) the row is a regular NavigationLink. On a
//  regular-width iPad the detail column is driven by `model.selection`, so
//  the row must set the selection instead of pushing a view: a view-based
//  link inside a NavigationSplitView sidebar takes over the detail column
//  and later sidebar taps stop switching pages.
//

import SwiftUI

struct AppleAccountHeaderRow: View {
    @Environment(PrimarySettingsListModel.self) private var model
    @Environment(SettingsStore.self) private var store
    @State private var showingSignInError = false
    @State private var showingSignInSheet = false

    private var isSelected: Bool {
        model.selection?.type == .primaryAppleAccount
    }

    var body: some View {
        if let account = store.account {
            if UIDevice.iPhone || model.isCompact {
                NavigationLink {
                    AppleAccountView()
                } label: {
                    signedInLabel(account, selected: false)
                }
            } else {
                Button {
                    if isSelected {
                        model.path = []
                    } else {
                        model.selection = model.appleAccountItem
                    }
                } label: {
                    HStack {
                        // No chevron on iPad; selection tints the text blue.
                        signedInLabel(account, selected: isSelected)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(isSelected ? .blue : .primary)
                .accessibilityIdentifier("com.apple.settings.primaryAppleAccount")
                .modifier(listRowBackgroundEffect(
                    isActive: UIDevice.iPad && !model.isCompact,
                    isSelected: isSelected
                ))
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

    private func signedInLabel(_ account: MockAppleAccount, selected: Bool) -> some View {
        HStack(spacing: 14) {
            AvatarView(account: account, size: 60)
            VStack(alignment: .leading, spacing: 2) {
                Text(account.fullName)
                    .font(.title2)
                Text("Apple Account, iCloud, and more")
                    .font(.footnote)
                    .foregroundStyle(selected ? AnyShapeStyle(.blue) : AnyShapeStyle(.secondary))
            }
        }
        .padding(.vertical, 6)
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
