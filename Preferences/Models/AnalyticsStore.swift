import Foundation
import Observation

struct AnalyticsFile: Identifiable, Hashable {
    let url: URL
    var id: URL { url }
    var name: String { url.lastPathComponent }
}

/// Real files on disk (Application Support/DiagnosticReports) so ShareLink works.
@Observable
final class AnalyticsStore {
    static let shared = AnalyticsStore()
    private(set) var files: [AnalyticsFile] = []

    let directory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appending(path: "DiagnosticReports", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        seedIfNeeded()
        syncCrashReports()
        reload()
    }

    /// Re-reads the directory and brings the generated crash reports up to
    /// date. Called when Analytics Data appears, so a day that rolled over
    /// while the app was open still shows up.
    func refresh() {
        syncCrashReports()
        reload()
    }

    /// Keeps the `cod-*.ips` reports in step with the calendar: writes the ones
    /// that are due and missing, deletes the ones that have aged out of the
    /// window. Reports already on disk are never rewritten, so a crash that is
    /// listed keeps its exact timestamp and contents until it expires.
    private func syncCrashReports() {
        let expected = CrashReportGenerator.reports()
        let expectedNames = Set(expected.map(\.name))
        let onDisk = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []

        for url in onDisk
        where url.lastPathComponent.hasPrefix(CrashReportGenerator.filePrefix)
            && !expectedNames.contains(url.lastPathComponent) {
            try? FileManager.default.removeItem(at: url)
        }

        for report in expected {
            let url = directory.appending(path: report.name)
            guard !FileManager.default.fileExists(atPath: url.path) else { continue }
            try? report.body.write(to: url, atomically: true, encoding: .utf8)
            // A report is as old as the crash it describes.
            try? FileManager.default.setAttributes(
                [.modificationDate: report.date, .creationDate: report.date],
                ofItemAtPath: url.path
            )
        }
    }

    func reload() {
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        files = urls.map(AnalyticsFile.init)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func contents(of file: AnalyticsFile) -> String {
        (try? String(contentsOf: file.url, encoding: .utf8)) ?? ""
    }

    func deleteAll() {
        for f in files { try? FileManager.default.removeItem(at: f.url) }
        reload()
    }

    /// ~40 files over the last 7 days on first launch, then a few new ones per launch.
    private func seedIfNeeded() {
        let existing = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        let days = existing.isEmpty ? 7 : 1
        for d in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
            write(AnalyticsFileTemplates.analytics(date: date))
            write(AnalyticsFileTemplates.logAggregated(date: date))
            if d % 2 == 0 { write(AnalyticsFileTemplates.jetsam(date: date)) }
            if d % 3 == 0 { write(AnalyticsFileTemplates.wifiLQM(date: date)) }
            if d == 0 && existing.isEmpty {
                write(AnalyticsFileTemplates.stacks(date: date))
                write(AnalyticsFileTemplates.awdd(date: date))
                write(AnalyticsFileTemplates.logPower(date: date))
            }
        }
    }

    private func write(_ f: (name: String, body: String)) {
        let url = directory.appending(path: f.name)
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        try? f.body.write(to: url, atomically: true, encoding: .utf8)
    }
}
