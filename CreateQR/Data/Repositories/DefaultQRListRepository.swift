//
//  DefaultQRListRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation
import UIKit

final class DefaultQRListRepository: QRListRepository {

    init() {}

    func fetchQRTypeList(
        completion: @escaping (Result<[QRTypeItem], Error>) -> Void
    ) -> Cancellable? {

        let task = RepositoryTask()

        // TODO: - 추후 네트워크 통신 추가

        let urlType = QRTypeItem(
            id: "defaultType",
            title: "Text",
            titleImage: UIImage(systemName: "safari"),
            detailImage: nil,
            type: .url
        )
        let wifiType = QRTypeItem(
            id: "wifiType",
            title: "Wifi",
            titleImage: UIImage(systemName: "wifi.router"),
            detailImage: nil,
            type: .wifi
        )
        let cardType = QRTypeItem(
            id: "type2",
            title: "Beta",
            titleImage: UIImage(systemName: "person.crop.square.filled.and.at.rectangle"),
            detailImage: nil,
            type: .card
        )

        completion(.success([urlType, wifiType, cardType]))

        return task
    }
}
