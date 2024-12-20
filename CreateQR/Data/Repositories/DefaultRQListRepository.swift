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
        
        let urlType = QRTypeItem(id: "type1", title: "URL", titleImage: UIImage(systemName: "safari"), detailImage: nil)
        let cardType = QRTypeItem(id: "type2", title: "Card", titleImage: UIImage(systemName: "person.crop.square.filled.and.at.rectangle"), detailImage: nil)
        completion(.success([urlType, cardType]))
        
        return task
    }
}
