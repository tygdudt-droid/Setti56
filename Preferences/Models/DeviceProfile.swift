//
//  DeviceProfile.swift
//  Preferences
//

import Foundation
import UIKit

/// The one description of "this device", shared by everything that has to
/// agree about it: Settings > General > About, and the crash reports listed in
/// Privacy & Security > Analytics & Improvements > Analytics Data.
///
/// Values come from `MockDeviceIdentity` (editable in the hidden Mock
/// Configuration panel) and fall back to what the hardware actually reports,
/// which is the same precedence `AboutView` uses.
enum DeviceProfile {
    private static var identity: MockDeviceIdentity { MockDeviceIdentity.stored }

    /// Hardware identifier — `modelCode` in a crash report. e.g. `iPad13,4`
    static var modelIdentifier: String {
        if let value = identity.modelIdentifier, !value.isEmpty { return value }
        return MockDevice.current.identifier
    }

    /// Marketing name shown in About. e.g. `iPad Pro 11-inch (3rd generation)`
    static var modelName: String {
        if let value = identity.modelName, !value.isEmpty { return value }
        // An overridden identifier names the device even when the marketing
        // name was left blank in Mock Configuration.
        if let identifier = identity.modelIdentifier, let known = MockDevice.knownModels[identifier] {
            return known
        }
        return MockDevice.current.modelName
    }

    /// e.g. `26.6.1`
    static var osVersion: String {
        if let value = identity.osVersion, !value.isEmpty { return value }
        return MockDevice.current.systemVersion
    }

    /// e.g. `23G83`
    static var build: String {
        if let value = identity.buildNumber, !value.isEmpty { return value }
        let reported = UIDevice.buildVersion
        return reported.isEmpty ? MockDevice.current.buildNumber : reported
    }

    /// Crash reports label every embedded OS as `iPhone OS`, iPadOS included.
    static let osTrainName = "iPhone OS"

    /// e.g. `iPhone OS 26.6.1`
    static var osTrain: String { "\(osTrainName) \(osVersion)" }

    /// e.g. `iPhone OS 26.6.1 (23G83)`
    static var osVersionFull: String { "\(osTrain) (\(build))" }

    /// Seed for values that are fixed for the life of an install but must not
    /// be shipped in the repository — the crash reporter key, the vendor
    /// identifier, the App Store cohort. Tied to the mock serial number, so
    /// regenerating the identity in Mock Configuration rotates them too.
    static var installSeed: UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in identity.serialNumber.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x1000_0000_01B3
        }
        return hash
    }
}
