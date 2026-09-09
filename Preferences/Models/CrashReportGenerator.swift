//
//  CrashReportGenerator.swift
//  Preferences
//

import Foundation

/// One crash report ready to be written into Analytics Data.
struct GeneratedCrashReport {
    /// `cod-2026-09-07-214646.ips`
    let name: String
    /// The moment the report was filed — the file name and the `timestamp`
    /// inside the report are two spellings of this same value.
    let date: Date
    let body: String
}

/// Produces the `cod-*.ips` watchdog reports listed under
/// Settings > Privacy & Security > Analytics & Improvements > Analytics Data.
///
/// One report lands per day and stays for `windowDays` days before ageing
/// out. Everything a report contains is derived from its own timestamp,
/// so re-running the generator rebuilds byte-identical files: yesterday's crash
/// keeps yesterday's time, pid, thread ids and stack for as long as it is
/// listed, and only disappears once it falls out of the window.
///
/// The device the reports describe comes from ``DeviceProfile``, which is the
/// same source Settings > General > About reads.
enum CrashReportGenerator {
    /// Days of history to keep, today included.
    static let windowDays = 7

    /// Prefix every generated file shares, used to age old ones out.
    static let filePrefix = "cod-"

    /// Apple silicon `mach_absolute_time` runs at 24 MHz.
    private static let machTicksPerSecond: Int64 = 24_000_000

    // MARK: - Public

    /// Every report that should be on disk right now, oldest first.
    ///
    /// Reports dated later today than `now` are left out — a device cannot
    /// have filed a crash report that has not happened yet.
    static func reports(now: Date = Date()) -> [GeneratedCrashReport] {
        let calendar = gregorian
        let formatters = Formatters()
        guard let today = calendar.dateInterval(of: .day, for: now)?.start else { return [] }

        var result: [GeneratedCrashReport] = []
        for daysBack in stride(from: windowDays - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }
            for date in crashTimes(on: day, calendar: calendar) where date <= now {
                result.append(report(at: date, formatters: formatters))
            }
        }
        return result
    }

    // MARK: - Schedule

    /// A Gregorian calendar with POSIX formatting, whatever locale the device
    /// is set to — file names must never come out with non-Latin digits.
    private static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    /// Play sessions run late, so most watchdog kills land in the evening and
    /// the early hours and almost none before breakfast.
    private static let hourWeights: [Int] = [
        // 0  1  2  3  4  5  6  7  8  9 10 11
           9, 7, 5, 2, 1, 1, 1, 1, 2, 3, 3, 4,
        //12 13 14 15 16 17 18 19 20 21 22 23
           5, 5, 6, 6, 7, 8, 10, 12, 13, 14, 13, 11
    ]

    /// The moment a crash was filed on the given day — one per day.
    private static func crashTimes(on day: Date, calendar: Calendar) -> [Date] {
        var rng = SeededGenerator(seed: seed(forDay: day, calendar: calendar))
        let hour = weightedHour(using: &rng)
        let minute = Int.random(in: 0...59, using: &rng)
        let second = Int.random(in: 0...59, using: &rng)
        guard let date = calendar.date(bySettingHour: hour, minute: minute, second: second, of: day) else {
            return []
        }
        return [date]
    }

    private static func weightedHour(using rng: inout SeededGenerator) -> Int {
        let total = hourWeights.reduce(0, +)
        var pick = Int.random(in: 0..<total, using: &rng)
        for (hour, weight) in hourWeights.enumerated() {
            pick -= weight
            if pick < 0 { return hour }
        }
        return 21
    }

    /// Stable across launches and independent of the display calendar.
    private static func seed(forDay day: Date, calendar: Calendar) -> UInt64 {
        let ordinal = calendar.ordinality(of: .day, in: .era, for: day) ?? 0
        return UInt64(bitPattern: Int64(ordinal)) &* 0x9E37_79B9_7F4A_7C15 ^ 0x0C0D_0C0D
    }

    private static func seed(forReportAt date: Date) -> UInt64 {
        UInt64(bitPattern: Int64(date.timeIntervalSince1970)) &* 0xBF58_476D_1CE4_E5B9 ^ 0x5EED
    }

    // MARK: - One report

    private static func report(at date: Date, formatters: Formatters) -> GeneratedCrashReport {
        var rng = SeededGenerator(seed: seed(forReportAt: date))

        let template = CODCrashTemplates.all[Int.random(in: 0..<CODCrashTemplates.all.count, using: &rng)]
        let release = AppRelease.stored

        // The session that ended in this crash, and the watchdog snapshot that
        // was taken a couple of seconds before the report was written out.
        let session = Double(Int.random(in: 20 * 60 ... 15 * 3600, using: &rng))
        let launchFraction = Double(Int.random(in: 0...9_999, using: &rng)) / 10_000
        let launch = date.addingTimeInterval(-session - launchFraction)
        let captureOffset = Double(Int.random(in: 2...9, using: &rng))
            + Double(Int.random(in: 0...9_999, using: &rng)) / 10_000
        let capture = date.addingTimeInterval(-captureOffset)

        // Uptime is reported rounded down to the nearest 10 000 seconds, so the
        // mach times are computed from the unrounded value.
        let trueUptime = session + Double(Int.random(in: 3_600 ... 216_000, using: &rng))
        let uptime = max(10_000, Int(trueUptime / 10_000) * 10_000)
        // Boots and launches never fall on a whole second, so neither do the
        // mach times a real report records.
        let exitJitter = Int64(Int.random(in: 0..<Int(machTicksPerSecond), using: &rng))
        let launchJitter = Int64(Int.random(in: 0..<Int(machTicksPerSecond), using: &rng))
        let exitTicks = Int64(trueUptime) * machTicksPerSecond + exitJitter
        let startTicks = max(
            machTicksPerSecond,
            exitTicks - Int64(session) * machTicksPerSecond - launchJitter
        )

        let pid = Int.random(in: 240...12_000, using: &rng)
        let coalitionID = Int.random(in: 200...2_000, using: &rng)
        let incident = uuidUpper(using: &rng)

        // Watchdog CPU statistics.
        let cpuTotal = Double(Int.random(in: 4_000...24_000, using: &rng)) / 1_000
        let cpuUser = (cpuTotal * Double(Int.random(in: 55...75, using: &rng)) / 100 * 1_000).rounded() / 1_000
        let cpuSystem = ((cpuTotal - cpuUser) * 1_000).rounded() / 1_000
        let cpuPercent = Int.random(in: 3...18, using: &rng)
        let cpuApp = Double(Int.random(in: 100...900, using: &rng)) / 1_000
        let cpuAppPercent = Int.random(in: 0...3, using: &rng)

        // Anything tied to the boot: two crashes from the same session share a
        // boot UUID and the same address-space slide, exactly like real reports.
        let bootDate = date.addingTimeInterval(-Double(uptime))
        var bootRNG = SeededGenerator(
            seed: UInt64(bitPattern: Int64(bootDate.timeIntervalSince1970 / 3_600)) &* 0x94D0_49BB_1331_11EB
        )
        let bootSession = uuidUpper(using: &bootRNG)
        let slide = Int64(Int.random(in: 0...8_192, using: &bootRNG)) * 16_384

        // Fixed for the life of the install, derived from the mock serial so
        // nothing device-specific has to be committed.
        var installRNG = SeededGenerator(seed: DeviceProfile.installSeed)
        let crashReporterKey = hexString(40, using: &installRNG)
        let vendorIdentifier = uuidUpper(using: &installRNG)
        let cohortPage = uuidLower(using: &installRNG)
        let cohortDate = Int.random(in: 1_690_000_000...1_760_000_000, using: &installRNG) * 1_000

        // Fixed per App Store release: the container is recreated on update,
        // and the log-writing signature follows the binary.
        var releaseRNG = SeededGenerator(seed: release.seed)
        let container = uuidUpper(using: &releaseRNG)
        let logSignature = hexString(40, using: &releaseRNG)

        let cohort = "10|date=\(cohortDate)&sf=143441&pgtp=Search&pgid=\(cohortPage)"
            + "&prpg=SearchLanding_SearchLanding&ctxt=Search&issrch=1&imptyp=card&kind=iosSoftware&lngid=1"

        let replacements: [String: String] = [
            "{{TIMESTAMP}}": formatters.stamp(date, fractionDigits: 2),
            "{{CAPTURE_TIME}}": formatters.stamp(capture, fractionDigits: 4),
            "{{PROC_LAUNCH}}": formatters.stamp(launch, fractionDigits: 4),
            "{{INCIDENT}}": incident,
            "{{PID}}": String(pid),
            "{{UPTIME}}": String(uptime),
            "{{COALITION_ID}}": String(coalitionID),
            "{{PROC_START_ABS}}": String(startTicks),
            "{{PROC_EXIT_ABS}}": String(exitTicks),
            "{{APP_VERSION}}": release.version,
            "{{APP_BUILD}}": release.build,
            "{{SLICE_UUID}}": release.sliceUUID,
            "{{SW_EXT_ID}}": release.externalIdentifier,
            "{{APP_CONTAINER}}": container,
            "{{LOG_SIGNATURE}}": logSignature,
            "{{BOOT_SESSION}}": bootSession,
            "{{CRASH_REPORTER_KEY}}": crashReporterKey,
            "{{IDFV}}": vendorIdentifier,
            "{{STORE_COHORT}}": cohort,
            "{{MODEL_CODE}}": DeviceProfile.modelIdentifier,
            "{{OS_TRAIN}}": DeviceProfile.osTrain,
            "{{OS_BUILD}}": DeviceProfile.build,
            "{{OS_VERSION_FULL}}": DeviceProfile.osVersionFull,
            "{{CPU_TOTAL}}": String(format: "%.3f", cpuTotal),
            "{{CPU_USER}}": String(format: "%.3f", cpuUser),
            "{{CPU_SYS}}": String(format: "%.3f", cpuSystem),
            "{{CPU_PCT}}": String(cpuPercent),
            "{{CPU_APP}}": String(format: "%.3f", cpuApp),
            "{{CPU_APP_PCT}}": String(cpuAppPercent)
        ]

        var body = template
        for (token, value) in replacements {
            body = body.replacingOccurrences(of: token, with: value)
        }
        body = applyThreadIdentifiers(to: body, using: &rng)
        body = applyImageSlide(to: body, slide: slide)

        return GeneratedCrashReport(
            name: "\(filePrefix)\(formatters.file.string(from: date)).ips",
            date: date,
            body: body
        )
    }

    // MARK: - Token passes that are not a plain substitution

    /// Thread identifiers climb through the report, the way the kernel hands
    /// them out over the life of a process.
    private static func applyThreadIdentifiers(to text: String, using rng: inout SeededGenerator) -> String {
        let token = "{{TID}}"
        var identifier = Int.random(in: 1_100_000...1_500_000, using: &rng)
        var result = ""
        result.reserveCapacity(text.count)

        var remainder = Substring(text)
        while let range = remainder.range(of: token) {
            result += remainder[remainder.startIndex..<range.lowerBound]
            result += String(identifier)
            identifier += Int.random(in: 1...400, using: &rng)
            remainder = remainder[range.upperBound...]
        }
        result += remainder
        return result
    }

    /// Shifts every loaded-image base (and the shared cache) by one per-boot
    /// slide, so reports from different boots do not share an address space.
    private static func applyImageSlide(to text: String, slide: Int64) -> String {
        let token = "{{IMG_BASE:"
        let parts = text.components(separatedBy: token)
        guard parts.count > 1 else { return text }

        var result = parts[0]
        for part in parts.dropFirst() {
            guard let end = part.range(of: "}}") else {
                result += token + part
                continue
            }
            let base = Int64(part[part.startIndex..<end.lowerBound]) ?? 0
            result += String(base + slide)
            result += part[end.upperBound...]
        }
        return result
    }

    // MARK: - Deterministic identifiers

    private static func hexString(_ length: Int, using rng: inout SeededGenerator) -> String {
        let digits = Array("0123456789abcdef")
        return String((0..<length).map { _ in digits[Int.random(in: 0..<16, using: &rng)] })
    }

    private static func uuidUpper(using rng: inout SeededGenerator) -> String {
        UUIDBuilder.make(version: 4, using: &rng, digits: Array("0123456789ABCDEF"))
    }

    private static func uuidLower(using rng: inout SeededGenerator) -> String {
        UUIDBuilder.make(version: 4, using: &rng, digits: Array("0123456789abcdef"))
    }

    // MARK: - Formatting

    /// Crash reports are always written in POSIX English against the Gregorian
    /// calendar, regardless of the device's own locale.
    private struct Formatters {
        /// `2026-09-07-214646` — the file name.
        let file = Formatters.make("yyyy-MM-dd-HHmmss")
        private let second = Formatters.make("yyyy-MM-dd HH:mm:ss")
        private let zone = Formatters.make("ZZZ")

        /// `2026-09-07 21:46:46.00 +0330` with two fractional digits, or
        /// `2026-09-07 21:46:43.9200 +0330` with four.
        ///
        /// The fraction is written by hand: `DateFormatter` only carries
        /// millisecond precision and pads anything finer with zeros, which
        /// would leave every capture time ending in `0`.
        func stamp(_ date: Date, fractionDigits: Int) -> String {
            let epoch = date.timeIntervalSince1970
            let whole = epoch.rounded(.down)
            let scale = pow(10, Double(fractionDigits))
            let fraction = min(scale - 1, ((epoch - whole) * scale).rounded(.down))
            let digits = String(format: "%0\(fractionDigits)d", Int(fraction))
            // Format the truncated second so it can never round up past it.
            let truncated = Date(timeIntervalSince1970: whole)
            return "\(second.string(from: truncated)).\(digits) \(zone.string(from: truncated))"
        }

        private static func make(_ format: String) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = .current
            formatter.dateFormat = format
            return formatter
        }
    }
}

// MARK: - UUIDs

/// Builds UUID strings that pass the same inspection a real one would: the
/// version nibble and the RFC 4122 variant bits are in the right places.
///
/// Crash reports mix two kinds — identifiers (incident, boot session, app
/// container, vendor ID) are random version 4, while a Mach-O `slice_uuid` is
/// a version 3 hash of the binary.
enum UUIDBuilder {
    static func make(version: Int, using rng: inout SeededGenerator, digits: [Character]) -> String {
        var characters = (0..<32).map { _ in digits[Int.random(in: 0..<16, using: &rng)] }
        characters[12] = digits[version]
        // Variant 1 (RFC 4122): the first digit of the fourth group is 8–B.
        characters[16] = digits[Int.random(in: 8...11, using: &rng)]

        var result = ""
        var index = 0
        for (position, length) in [8, 4, 4, 4, 12].enumerated() {
            if position > 0 { result += "-" }
            result += String(characters[index..<(index + length)])
            index += length
        }
        return result
    }
}

// MARK: - The installed build

/// The Call of Duty: Mobile build the device is running, as a crash report
/// records it.
///
/// The version, build number and Mach-O slice UUID belong together — they all
/// come from one binary — so they are stored and edited as a unit rather than
/// picked apart. Mock Configuration writes this; every report reads it.
struct AppRelease: Codable, Equatable {
    var version: String
    var build: String
    var sliceUUID: String
    var externalIdentifier: String

    /// Seed for values that stay fixed for as long as this build is installed:
    /// the app's container directory and its log-writing signature.
    var seed: UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in (build + sliceUUID).utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x1000_0000_01B3
        }
        return hash
    }

    /// The build shipped in the templates.
    static let current = AppRelease(
        version: "1.0.57",
        build: "202609040",
        sliceUUID: "c8f79c32-66eb-3583-97e3-a1e1e71a5a09",
        externalIdentifier: "890840685"
    )

    private static let storageKey = "cod.release"

    static var stored: AppRelease {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let value = try? JSONDecoder().decode(AppRelease.self, from: data)
        else { return .current }
        return value
    }

    func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(self), forKey: Self.storageKey)
    }
}
