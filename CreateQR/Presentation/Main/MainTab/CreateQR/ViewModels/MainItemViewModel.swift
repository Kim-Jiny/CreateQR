//
//  MainItemViewModel.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

struct MainItemViewModel: Equatable {
    typealias Identifier = String
    let id: Identifier
    let title: String
    let titleImage: UIImage?
    let detailImage: UIImage?
    let typeView: UIView
}

extension MainItemViewModel {

    init(qrType: QRTypeItem) {
        self.id = qrType.id
        self.title = qrType.title ?? "unnkown"
        self.titleImage = qrType.titleImage
        self.detailImage = qrType.detailImage
        self.typeView = CreateQRURLType()
    }
}
