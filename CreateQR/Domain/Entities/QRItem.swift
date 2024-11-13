//
//  QRItem.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import Foundation

struct QRItem: Equatable, Codable {
    typealias Identifier = String
    let id: Identifier
    let title: String
    let qrImageData: Data?
    let createdAt: TimeInterval
    let qrType: CreateType
}

extension QRItem {
    
    init(title: String, qrImageData: Data?, qrType: CreateType) {
        self.id = UUID().uuidString
        self.title = title
        self.qrImageData = qrImageData
        self.createdAt = TimestampProvider().getCurrentTimestamp()
        self.qrType = qrType
    }
}
