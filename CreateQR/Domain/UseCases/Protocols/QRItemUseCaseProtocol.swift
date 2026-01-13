//
//  QRItemUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation

protocol QRItemUseCaseProtocol {
    func getQRItems() -> [QRItem]?
    func addQRItem(_ item: QRItem)
    func saveQRList(_ items: [QRItem])
    func updateQRItem(_ item: QRItem)
    func removeQRItem(_ item: QRItem)
}
