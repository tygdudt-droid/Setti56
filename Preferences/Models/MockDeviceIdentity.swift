import Foundation

/// Deterministic per-install fake identifiers (serial, IMEI, MAC…).
struct MockDeviceIdentity: Codable {
    var serialNumber: String
    var imei: String
    var imei2: String
    var eid: String
    var seid: String
    var wifiAddress: String
    var bluetoothAddress: String
    var modemFirmware: String
    var modelNumber: String
    var regulatoryModel: String
    var iccid: String

    static var stored: MockDeviceIdentity {
        if let data = UserDefaults.standard.data(forKey: "mock.identity"),
           let id = try? JSONDecoder().decode(MockDeviceIdentity.self, from: data) { return id }
        let id = generate()
        UserDefaults.standard.set(try? JSONEncoder().encode(id), forKey: "mock.identity")
        return id
    }

    private static func generate() -> MockDeviceIdentity {
        let hexChars = Array("0123456789ABCDEF")
        let alnum = Array("ABCDEFGHJKLMNPQRSTUVWXYZ0123456789")
        let letters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")
        func hex(_ n: Int) -> String { String((0..<n).map { _ in hexChars.randomElement()! }) }
        func digits(_ n: Int) -> String { (0..<n).map { _ in String(Int.random(in: 0...9)) }.joined() }
        func mac() -> String { (0..<6).map { _ in hex(2) }.joined(separator: ":") }
        return MockDeviceIdentity(
            serialNumber: String((0..<10).map { _ in alnum.randomElement()! }),
            imei: "35 " + digits(6) + " " + digits(6) + " " + digits(1),
            imei2: "35 " + digits(6) + " " + digits(6) + " " + digits(1),
            eid: digits(32),
            seid: hex(40),
            wifiAddress: mac(),
            bluetoothAddress: mac(),
            modemFirmware: "1.\(Int.random(in: 0...3))0.0\(Int.random(in: 1...9))",
            modelNumber: "M" + String(letters.randomElement()!) + String(letters.randomElement()!) + digits(2) + "LL/A",
            regulatoryModel: "A\(Int.random(in: 3200...3399))",
            iccid: "8901" + digits(16))
    }
}
