//
//  QRItemUseCase.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import Foundation

class QRItemUseCase {
    private let repository: QRItemRepository

    init(repository: QRItemRepository) {
        self.repository = repository
    }

    func getQRItems() -> [QRItem]? {
        return repository.loadQRItems()
    }

    func addQRItem(_ item: QRItem) {
        repository.addQRItem(newItem: item)
    }
    
    func saveQRList(_ items: [QRItem]) {
        repository.saveQRItems(qrItems: items)
    }
    
    func updateQRItem(_ item: QRItem) {
        repository.updateQRItem(item: item)
    }
}
