//
//  QRItemRepository.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import Foundation

class QRItemRepository {
    private let key = "QRItemViewModels"

    // QRItem 목록 저장
    func saveQRItems(qrItems: [QRItem]) {
        do {
            let data = try JSONEncoder().encode(qrItems)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save QRItems: \(error)")
        }
    }

    // QRItem 목록 불러오기
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

    // QRItem 하나 추가
    func addQRItem(newItem: QRItem) {
        var qrItems = loadQRItems() ?? []
        qrItems.append(newItem)
        saveQRItems(qrItems: qrItems)
    }
    
    // QRItem 업데이트
    func updateQRItem(item: QRItem) {
        var qrItems = loadQRItems() ?? []

        // 업데이트할 항목의 인덱스 찾기
        if let index = qrItems.firstIndex(where: { $0.id == item.id }) {
            qrItems[index] = item // 해당 인덱스의 항목을 업데이트된 항목으로 변경
            saveQRItems(qrItems: qrItems) // 변경 사항 저장
        } else {
            print("Item with ID \(item.id) not found.")
        }
    }
}
