//
//  QRItem.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import Foundation
import UIKit

enum LogoStyle: Codable {
    case circle, square
}

struct QRItem: Equatable, Codable {
    typealias Identifier = String
    let id: Identifier
    var title: String
    let qrImageData: Data?
    let createdAt: TimeInterval
    let qrType: CreateType
    let qrData: String
    
    let qrColor: String
    let backColor: String
    let logo: Data?
    var logoStyle: LogoStyle
    
    // 직접 디코딩 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        qrImageData = try? container.decode(Data.self, forKey: .qrImageData)
        createdAt = (try? container.decode(TimeInterval.self, forKey: .createdAt)) ?? 0.0
        qrType = (try? container.decode(CreateType.self, forKey: .qrType)) ?? .url
        qrData = (try? container.decode(String.self, forKey: .qrData)) ?? ""
        qrColor = (try? container.decode(String.self, forKey: .qrColor)) ?? ""
        backColor = (try? container.decode(String.self, forKey: .backColor)) ?? ""
        logo = try? container.decode(Data.self, forKey: .logo)
        logoStyle = (try? container.decode(LogoStyle.self, forKey: .logoStyle)) ?? .square
    }
}

extension QRItem {
    
    init(title: String, qrImageData: Data?, qrType: CreateType, qrData: String, qrColor: String, backColor: String, logo: Data?, logoStyle: LogoStyle) {
        self.id = UUID().uuidString
        self.title = title
        self.qrImageData = qrImageData
        self.createdAt = TimestampProvider().getCurrentTimestamp()
        self.qrType = qrType
        self.qrData = qrData
        self.qrColor = qrColor
        self.backColor = backColor
        self.logo = logo
        self.logoStyle = logoStyle
    }
}
