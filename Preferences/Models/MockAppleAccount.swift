import Foundation

struct MockAppleAccount: Codable, Equatable {
    var email: String
    var firstName: String
    var lastName: String
    var avatarData: Data?
    var signedInAt: Date

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { String(firstName.prefix(1) + lastName.prefix(1)).uppercased() }

    /// Derive a plausible name from whatever the user typed.
    static func from(email: String) -> MockAppleAccount {
        let local = email.split(separator: "@").first.map(String.init) ?? "Apple User"
        let parts = local.split(whereSeparator: { ".-_".contains($0) }).map { $0.capitalized }
        return MockAppleAccount(email: email,
                                firstName: parts.first ?? "Apple",
                                lastName: parts.dropFirst().first ?? "User",
                                avatarData: nil,
                                signedInAt: .now)
    }
}
