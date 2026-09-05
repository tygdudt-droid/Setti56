import Foundation
import UIKit

struct MockLinkedDevice: Identifiable, Codable, Hashable {
    enum Kind: String, CaseIterable, Codable {
        case iPhone, iPad, Mac, Watch, AirPods
        var symbol: String {
            switch self {
            case .iPhone: return "iphone"
            case .iPad: return "ipad.landscape"
            case .Mac: return "macbook"
            case .Watch: return "applewatch"
            case .AirPods: return "airpodspro"
            }
        }
    }

    var id = UUID()
    var name: String
    var kind: Kind
    var model: String = ""

    static let defaults: [MockLinkedDevice] = [
        MockLinkedDevice(name: UIDevice.current.name, kind: UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone)
    ]

    private enum CodingKeys: String, CodingKey { case name, kind, model }

    init(name: String, kind: Kind, model: String = "") {
        self.id = UUID()
        self.name = name
        self.kind = kind
        self.model = model
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        name = try c.decode(String.self, forKey: .name)
        kind = try c.decode(Kind.self, forKey: .kind)
        model = try c.decodeIfPresent(String.self, forKey: .model) ?? ""
    }
}

struct MockAppleAccount: Codable, Equatable {
    var email: String
    var firstName: String
    var lastName: String
    var avatarData: Data?
    var signedInAt: Date
    var devices: [MockLinkedDevice] = []

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { String(firstName.prefix(1) + lastName.prefix(1)).uppercased() }
    var deviceList: [MockLinkedDevice] { devices }

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

    private enum CodingKeys: String, CodingKey {
        case email, firstName, lastName, avatarData, signedInAt, devices
    }

    init(email: String, firstName: String, lastName: String,
         avatarData: Data?, signedInAt: Date, devices: [MockLinkedDevice] = []) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarData = avatarData
        self.signedInAt = signedInAt
        self.devices = devices
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        email = try c.decode(String.self, forKey: .email)
        firstName = try c.decode(String.self, forKey: .firstName)
        lastName = try c.decode(String.self, forKey: .lastName)
        avatarData = try c.decodeIfPresent(Data.self, forKey: .avatarData)
        signedInAt = try c.decode(Date.self, forKey: .signedInAt)
        devices = try c.decodeIfPresent([MockLinkedDevice].self, forKey: .devices) ?? []
    }
}
