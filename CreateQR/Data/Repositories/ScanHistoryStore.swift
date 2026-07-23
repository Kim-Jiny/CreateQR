//
//  ScanHistoryStore.swift
//  CreateQR
//
//  Persists a rolling history of scanned QR contents (camera + gallery).
//

import Foundation

struct ScanRecord: Codable, Equatable {
    let id: String
    let content: String
    let scannedAt: TimeInterval

    init(content: String, scannedAt: TimeInterval) {
        self.id = UUID().uuidString
        self.content = content
        self.scannedAt = scannedAt
    }
}

struct ScanHistoryStore {
    private let key = "QRScanHistory"
    private let maxCount = 200
    private let defaults = UserDefaults.standard

    func load() -> [ScanRecord] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ScanRecord].self, from: data)) ?? []
    }

    private func save(_ records: [ScanRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: key)
        }
    }

    /// Prepends a new scan. Skips if identical to the most recent entry (avoids dupes
    /// from the camera re-reading the same code). Returns the updated list.
    @discardableResult
    func add(content: String, at timestamp: TimeInterval) -> [ScanRecord] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return load() }
        var records = load()
        if records.first?.content == trimmed { return records }
        records.insert(ScanRecord(content: trimmed, scannedAt: timestamp), at: 0)
        if records.count > maxCount { records = Array(records.prefix(maxCount)) }
        save(records)
        return records
    }

    @discardableResult
    func delete(id: String) -> [ScanRecord] {
        let records = load().filter { $0.id != id }
        save(records)
        return records
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
