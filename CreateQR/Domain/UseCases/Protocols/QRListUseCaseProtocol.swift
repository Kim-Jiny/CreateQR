//
//  QRListUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation

protocol GetQRListUseCaseProtocol {
    func execute(completion: @escaping (Result<[QRTypeItem], Error>) -> Void) -> Cancellable?
}
