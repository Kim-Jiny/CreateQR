//
//  QRItemRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation

protocol QRItemRepositoryProtocol {
    func saveQRItems(qrItems: [QRItem])
    func loadQRItems() -> [QRItem]?
    func addQRItem(newItem: QRItem)
    func updateQRItem(item: QRItem)
    func removeQRItem(item: QRItem)
}
