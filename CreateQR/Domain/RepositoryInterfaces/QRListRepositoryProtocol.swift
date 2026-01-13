//
//  QRListRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation

protocol QRListRepositoryProtocol {
    @discardableResult
    func fetchQRTypeList(completion: @escaping (Result<[QRTypeItem], Error>) -> Void) -> Cancellable?
}
