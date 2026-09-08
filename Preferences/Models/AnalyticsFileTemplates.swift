import Foundation

enum AnalyticsFileTemplates {
    private static let stamp: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd-HHmmss"
        return f
    }()
    private static let iso = ISO8601DateFormatter()
    /// Same device string the crash reports and Settings > General > About use.
    private static var osVersion: String { DeviceProfile.osVersionFull }

    private static func header(_ date: Date, bugType: String = "211", extra: String = "") -> String {
        "{\"bug_type\":\"\(bugType)\",\"timestamp\":\"\(iso.string(from: date))\",\"os_version\":\"\(osVersion)\",\"roots_installed\":0,\"incident_id\":\"\(UUID().uuidString)\"\(extra)}"
    }

    static func analytics(date: Date) -> (name: String, body: String) {
        let names = ["com.apple.power.battery.log", "com.apple.Preferences.usage", "com.apple.springboard.launch",
                     "com.apple.wifi.assoc", "com.apple.cellular.datausage", "com.apple.thermal.state"]
        let events = ["PowerlogEvent", "AppLaunch", "WiFiAssociation", "ThermalLevel", "CellularUsage"]
        let body = (0..<40).map { _ -> String in
            let t = date.addingTimeInterval(-Double.random(in: 0...86_400))
            return "{\"message\":{\"name\":\"\(names.randomElement()!)\",\"summarizationCount\":\(Int.random(in: 1...900)),\"sampleCount\":\(Int.random(in: 1...60))},\"name\":\"\(events.randomElement()!)\",\"uuid\":\"\(UUID().uuidString)\",\"timestamp\":\"\(iso.string(from: t))\"}"
        }.joined(separator: "\n")
        return ("Analytics-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }

    static func logAggregated(date: Date) -> (name: String, body: String) {
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        \t<key>osVersion</key>
        \t<string>\(osVersion)</string>
        \t<key>scalars</key>
        \t<dict>
        \t\t<key>com.apple.power.batteryDrainRate</key>
        \t\t<integer>\(Int.random(in: 3...9))</integer>
        \t\t<key>com.apple.springboard.homeScreenTime</key>
        \t\t<integer>\(Int.random(in: 900...12_000))</integer>
        \t\t<key>com.apple.wifi.numberOfAssociations</key>
        \t\t<integer>\(Int.random(in: 2...40))</integer>
        \t\t<key>com.apple.backboardd.displayOnTime</key>
        \t\t<integer>\(Int.random(in: 5_000...30_000))</integer>
        \t</dict>
        </dict>
        </plist>
        """
        return ("log-aggregated-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "211") + "\n" + plist)
    }

    static func jetsam(date: Date) -> (name: String, body: String) {
        let procs = ["MobileSafari", "SpringBoard", "mediaserverd", "Preferences", "backboardd", "photoanalysisd"]
        let body = """
        {
          "reason" : "per-process-limit",
          "largestProcess" : "\(procs.randomElement()!)",
          "memoryStatus" : { "pageSize" : 16384, "memoryPages" : { "active" : \(Int.random(in: 60_000...90_000)), "free" : \(Int.random(in: 4_000...9_000)), "wired" : \(Int.random(in: 30_000...45_000)) } },
          "processes" : [
            { "name" : "SpringBoard", "pid" : 58, "rpages" : \(Int.random(in: 20_000...40_000)), "states" : ["frontmost", "resident"] },
            { "name" : "\(procs.randomElement()!)", "pid" : \(Int.random(in: 300...9_000)), "rpages" : \(Int.random(in: 40_000...90_000)), "states" : ["suspended"] , "killDelta" : 0 }
          ]
        }
        """
        return ("JetsamEvent-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "298") + "\n" + body)
    }

    static func wifiLQM(date: Date) -> (name: String, body: String) {
        let body = (0..<12).map { i -> String in
            "{\"t\":\"\(iso.string(from: date.addingTimeInterval(Double(i) * -3600)))\",\"rssi\":\(Int.random(in: -75 ... -40)),\"snr\":\(Int.random(in: 18...45)),\"txRate\":\(Int.random(in: 86...866)),\"channel\":\([1, 6, 11, 36, 44, 149].randomElement()!),\"lqm\":\(Int.random(in: 40...100))}"
        }.joined(separator: "\n")
        return ("WiFiLQMMetrics-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }

    static func stacks(date: Date) -> (name: String, body: String) {
        let body = """
        Date/Time:        \(date)
        OS Version:       \(osVersion)
        Reason:           periodic stackshot
        Trigger:          sysdiagnose

        Process:          SpringBoard [58]
        Thread 0x1a2b  DispatchQueue "com.apple.main-thread"
          0  libsystem_kernel.dylib  mach_msg2_trap + 8
          1  libsystem_kernel.dylib  mach_msg2_internal + 80
          2  CoreFoundation          __CFRunLoopServiceMachPort + 160
          3  CoreFoundation          __CFRunLoopRun + 1212
          4  CoreFoundation          CFRunLoopRunSpecific + 588
          5  GraphicsServices        GSEventRunModal + 164
          6  UIKitCore               -[UIApplication _run] + 816
          7  UIKitCore               UIApplicationMain + 340
        """
        return ("stacks-\(stamp.string(from: date)).ips.ca.synced", header(date, bugType: "288") + "\n" + body)
    }

    static func awdd(date: Date) -> (name: String, body: String) {
        let body = (0..<30).map { _ in
            "\(Int.random(in: 100_000...999_999))\t\(["wifi", "cellular", "bluetooth", "location"].randomElement()!)\t\(Int.random(in: 0...1_000))"
        }.joined(separator: "\n")
        return ("awdd-\(stamp.string(from: date)).metriclog", body)
    }

    static func logPower(date: Date) -> (name: String, body: String) {
        let body = (0..<24).map { h in
            "\(iso.string(from: date.addingTimeInterval(Double(h) * -3600)))\tlevel=\(Int.random(in: 10...100))\tcharging=\(Bool.random())\tthermal=\(["nominal", "fair", "serious"].randomElement()!)"
        }.joined(separator: "\n")
        return ("log-power-\(stamp.string(from: date)).ips.ca.synced", header(date) + "\n" + body)
    }
}
