//
//  FetchAppVersionUseCase.swift
//  CreateQR
//
//  Created by 김미진 on 11/14/24.
//

import Foundation

protocol FetchAppVersionUseCase {
    func execute(completion: @escaping (String?) -> Void)
}

final class DefaultFetchAppVersionUseCase: FetchAppVersionUseCase {
    private let repository: AppVersionRepository
    
    init(repository: AppVersionRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (String?) -> Void) {
        repository.fetchLatestAppStoreVersion { latestVersion in
            completion(latestVersion)
        }
    }
}
