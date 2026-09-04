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
        reload()
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
