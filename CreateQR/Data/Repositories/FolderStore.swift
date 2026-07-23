//
//  FolderStore.swift
//  CreateQR
//
//  Persists the user's QR folder names (drill-down organization for My QR).
//  Folder membership itself lives on each QRItem.folderName; this store keeps the
//  ordered folder list so empty folders can exist and be renamed/deleted.
//

import Foundation

/// Which subset of the My QR list a folder-contents screen shows.
enum FolderFilter: Equatable {
    case pinned
    case folder(String)
    case uncategorized

    /// Predicate for whether a QR item belongs in this filter.
    func matches(_ item: QRItem) -> Bool {
        switch self {
        case .pinned: return item.isPinned
        case .folder(let name): return item.folderName == name
        case .uncategorized: return item.folderName == nil
        }
    }
}

struct FolderStore {
    private let key = "QRFolders"
    private let defaults = UserDefaults.standard

    func loadFolders() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func saveFolders(_ folders: [String]) {
        defaults.set(folders, forKey: key)
    }

    /// Adds a folder if the (trimmed, non-empty, unique) name is valid. Returns the stored name or nil.
    @discardableResult
    func addFolder(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var folders = loadFolders()
        guard !folders.contains(trimmed) else { return nil }
        folders.append(trimmed)
        saveFolders(folders)
        return trimmed
    }

    /// Renames a folder. Returns the new name if applied.
    @discardableResult
    func renameFolder(_ old: String, to new: String) -> String? {
        let trimmed = new.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var folders = loadFolders()
        guard let idx = folders.firstIndex(of: old), !folders.contains(trimmed) else { return nil }
        folders[idx] = trimmed
        saveFolders(folders)
        return trimmed
    }

    func deleteFolder(_ name: String) {
        saveFolders(loadFolders().filter { $0 != name })
    }
}
