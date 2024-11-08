//
//  QRListRepository.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation

protocol QRListRepository {
    @discardableResult
    func fetchQRTypeList(
        completion: @escaping (Result<[QRTypeItem], Error>) -> Void
    ) -> Cancellable?
}
