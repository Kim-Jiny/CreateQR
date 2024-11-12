//
//  IntervalUnit.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit

enum CreateType {
    case url, card
}
struct QRTypeItem: Equatable, Identifiable {
    typealias Identifier = String
    let id: Identifier
    let title: String?
    let titleImage: UIImage?
    let detailImage: UIImage?
    let type: CreateType
}
