//
//  DefaultQRItemRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation

final class DefaultQRItemRepository: QRItemRepositoryProtocol {

    private let key = "QRItemViewModels"

    // MARK: - QRItem 목록 저장

    func saveQRItems(qrItems: [QRItem]) {
        do {
            let data = try JSONEncoder().encode(qrItems)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save QRItems: \(error)")
        }
    }

    // MARK: - QRItem 목록 불러오기

    func loadQRItems() -> [QRItem]? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        do {
            let items = try JSONDecoder().decode([QRItem].self, from: data)
            return items
        } catch {
            print("Failed to load QRItems: \(error)")
            return nil
        }
    }

    // MARK: - QRItem 하나 추가

    func addQRItem(newItem: QRItem) {
        var qrItems = loadQRItems() ?? []

        if qrItems.contains(where: { $0.id == newItem.id }) {
            print("Item with ID \(newItem.id) already exists.")
            return
        }

        qrItems.append(newItem)
        saveQRItems(qrItems: qrItems)
    }

    // MARK: - QRItem 업데이트

    func updateQRItem(item: QRItem) {
        var qrItems = loadQRItems() ?? []

        if let index = qrItems.firstIndex(where: { $0.id == item.id }) {
            qrItems[index] = item
            saveQRItems(qrItems: qrItems)
        } else {
            print("Item with ID \(item.id) not found.")
        }
    }

    // MARK: - QRItem 삭제

    func removeQRItem(item: QRItem) {
        var qrItems = loadQRItems() ?? []

        if let index = qrItems.firstIndex(where: { $0.id == item.id }) {
            qrItems.remove(at: index)
            saveQRItems(qrItems: qrItems)
        } else {
            print("Item with ID \(item.id) not found.")
        }
    }
}
