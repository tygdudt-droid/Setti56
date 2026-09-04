import UIKit

/// Crash-free device information (public API only).
struct MockDevice {
    static let current = MockDevice()

    let identifier: String = {
        if let sim = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] { return sim }
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: max(size, 1))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }()

    var isSimulator: Bool { ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] != nil }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var isPhone: Bool { !isPad }
    var deviceTypeName: String { isPad ? "iPad" : "iPhone" }

    /// Never traps – unknown identifiers fall back to UIDevice.model.
    var modelName: String { MockDevice.knownModels[identifier] ?? UIDevice.current.model }
    var systemName: String { UIDevice.current.systemName }
    var systemVersion: String { UIDevice.current.systemVersion }
    var buildNumber: String { "23A340" }
    var deviceName: String { UIDevice.current.name }

    /// Adaptive Power exists on iPhone 15 Pro and newer (not 16e).
    var supportsAdaptivePower: Bool {
        identifier.hasPrefix("iPhone16,") ||
        (identifier.hasPrefix("iPhone17,") && identifier != "iPhone17,5") ||
        identifier.hasPrefix("iPhone18,")
    }

    static let knownModels: [String: String] = [
        "iPhone14,7": "iPhone 14", "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro", "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15", "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro", "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro", "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16", "iPhone17,4": "iPhone 16 Plus", "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17 Pro", "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17", "iPhone18,4": "iPhone Air",
        "iPad14,3": "iPad Pro 11-inch (4th generation)", "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
        "iPad16,3": "iPad Pro 11-inch (M4)", "iPad16,5": "iPad Pro 13-inch (M4)",
        "iPad14,8": "iPad Air 11-inch (M2)", "iPad14,10": "iPad Air 13-inch (M2)",
        "iPad15,3": "iPad Air 11-inch (M3)", "iPad15,5": "iPad Air 13-inch (M3)",
        "iPad15,7": "iPad (A16)", "iPad16,1": "iPad mini (A17 Pro)"
    ]
}
