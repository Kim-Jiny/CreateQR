//
//  AppVersionRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation

protocol AppVersionRepositoryProtocol {
    func fetchLatestAppStoreVersion(completion: @escaping (String?) -> Void)
}
