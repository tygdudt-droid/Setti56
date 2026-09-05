import Foundation

/// Deterministic per-install fake identifiers (serial, IMEI, MAC…),
/// editable from the hidden Mock Configuration panel.
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
    var modelName: String? = nil
    var osVersion: String? = nil
    var buildNumber: String? = nil
    var capacity: String? = nil
    var available: String? = nil

    static var stored: MockDeviceIdentity {
        if let data = UserDefaults.standard.data(forKey: "mock.identity"),
           let id = try? JSONDecoder().decode(MockDeviceIdentity.self, from: data) { return id }
        let id = generate()
        UserDefaults.standard.set(try? JSONEncoder().encode(id), forKey: "mock.identity")
        return id
    }

    /// Overwrites the persisted identity (used by "Regenerate Identifiers").
    static func regenerate() -> MockDeviceIdentity {
        let id = generate()
        UserDefaults.standard.set(try? JSONEncoder().encode(id), forKey: "mock.identity")
        return id
    }

    /// Persists edits made in Mock Configuration.
    func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(self), forKey: "mock.identity")
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

    private enum CodingKeys: String, CodingKey {
        case serialNumber, imei, imei2, eid, seid, wifiAddress, bluetoothAddress
        case modemFirmware, modelNumber, regulatoryModel, iccid
        case modelName, osVersion, buildNumber, capacity, available
    }

    init(serialNumber: String, imei: String, imei2: String, eid: String, seid: String,
         wifiAddress: String, bluetoothAddress: String, modemFirmware: String,
         modelNumber: String, regulatoryModel: String, iccid: String) {
        self.serialNumber = serialNumber
        self.imei = imei
        self.imei2 = imei2
        self.eid = eid
        self.seid = seid
        self.wifiAddress = wifiAddress
        self.bluetoothAddress = bluetoothAddress
        self.modemFirmware = modemFirmware
        self.modelNumber = modelNumber
        self.regulatoryModel = regulatoryModel
        self.iccid = iccid
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        serialNumber = try c.decode(String.self, forKey: .serialNumber)
        imei = try c.decode(String.self, forKey: .imei)
        imei2 = try c.decode(String.self, forKey: .imei2)
        eid = try c.decode(String.self, forKey: .eid)
        seid = try c.decode(String.self, forKey: .seid)
        wifiAddress = try c.decode(String.self, forKey: .wifiAddress)
        bluetoothAddress = try c.decode(String.self, forKey: .bluetoothAddress)
        modemFirmware = try c.decode(String.self, forKey: .modemFirmware)
        modelNumber = try c.decode(String.self, forKey: .modelNumber)
        regulatoryModel = try c.decode(String.self, forKey: .regulatoryModel)
        iccid = try c.decode(String.self, forKey: .iccid)
        modelName = try c.decodeIfPresent(String.self, forKey: .modelName)
        osVersion = try c.decodeIfPresent(String.self, forKey: .osVersion)
        buildNumber = try c.decodeIfPresent(String.self, forKey: .buildNumber)
        capacity = try c.decodeIfPresent(String.self, forKey: .capacity)
        available = try c.decodeIfPresent(String.self, forKey: .available)
    }
}
