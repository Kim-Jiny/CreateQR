//
//  AppVersionUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation

protocol FetchAppVersionUseCaseProtocol {
    func execute(completion: @escaping (String?) -> Void)
}
