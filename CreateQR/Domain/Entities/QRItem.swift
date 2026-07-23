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
    var isPinned: Bool
    /// Name of the folder this item belongs to. `nil` = uncategorized.
    var folderName: String?

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
        isPinned = (try? container.decode(Bool.self, forKey: .isPinned)) ?? false
        folderName = try? container.decode(String.self, forKey: .folderName)
    }
}

extension QRItem {
    init(
        id: Identifier,
        title: String,
        qrImageData: Data?,
        createdAt: TimeInterval,
        qrType: CreateType,
        qrData: String,
        qrColor: String,
        backColor: String,
        logo: Data?,
        logoStyle: LogoStyle,
        isPinned: Bool = false,
        folderName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.qrImageData = qrImageData
        self.createdAt = createdAt
        self.qrType = qrType
        self.qrData = qrData
        self.qrColor = qrColor
        self.backColor = backColor
        self.logo = logo
        self.logoStyle = logoStyle
        self.isPinned = isPinned
        self.folderName = folderName
    }

    init(title: String, qrImageData: Data?, qrType: CreateType, qrData: String, qrColor: String, backColor: String, logo: Data?, logoStyle: LogoStyle) {
        self.init(
            id: UUID().uuidString,
            title: title,
            qrImageData: qrImageData,
            createdAt: TimestampProvider().getCurrentTimestamp(),
            qrType: qrType,
            qrData: qrData,
            qrColor: qrColor,
            backColor: backColor,
            logo: logo,
            logoStyle: logoStyle,
            isPinned: false,
            folderName: nil
        )
    }
}
