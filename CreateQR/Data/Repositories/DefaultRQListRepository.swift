//
//  DefaultRQListRepository.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit

final class DefaultRQListRepository {
    init() { }
}

extension DefaultRQListRepository: QRListRepository {
    
    func fetchQRTypeList(
        completion: @escaping (Result<[QRTypeItem], Error>) -> Void
    ) -> Cancellable? {
        
        let task = RepositoryTask()
        
        //  MARK: - 추후 통신이 추가해야함.
        
        let urlType = QRTypeItem(id: "defaultType", title: "Text", titleImage: UIImage(systemName: "safari"), detailImage: nil, type: .url)
        let wifiType = QRTypeItem(id: "wifiType", title: "Wifi", titleImage: UIImage(systemName: "wifi.router"), detailImage: nil, type: .wifi)
        let bankTransferType = QRTypeItem(id: "bankTransferType", title: NSLocalizedString("Bank Transfer", comment: "Bank Transfer QR"), titleImage: UIImage(systemName: "wonsign.circle"), detailImage: nil, type: .bankTransfer)
        let contactType = QRTypeItem(id: "contactType", title: NSLocalizedString("Contact", comment: "Contact QR"), titleImage: UIImage(systemName: "person.crop.circle"), detailImage: nil, type: .contact)
        let instagramType = QRTypeItem(id: "instagramType", title: "Instagram", titleImage: UIImage(systemName: "camera.circle"), detailImage: nil, type: .instagram)
        completion(.success([urlType, wifiType, bankTransferType, contactType, instagramType]))
        
        return task
    }
}
