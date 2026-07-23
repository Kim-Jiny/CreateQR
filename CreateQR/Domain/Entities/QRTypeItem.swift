//
//  QRTypeItem.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit

enum CreateType: Codable {
    case url, card, menu, other
    case wifi
    case contact
    case instagram
    case youtube
    case tiktok
    case email
    case phone
    case sms
    case geo
    case calendar
}

struct QRTypeItem: Equatable, Identifiable {
    typealias Identifier = String
    let id: Identifier
    let title: String?
    let titleImage: UIImage?
    let detailImage: UIImage?
    let type: CreateType
}
