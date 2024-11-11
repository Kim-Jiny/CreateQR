//
//  PermissionUseCase.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import Photos

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
}

protocol PermissionUseCase {
    func checkCameraPermission(completion: @escaping (Bool) -> Void)
    func checkPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void)
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void)
}

class PermissionUseCaseImpl: PermissionUseCase {
    private let repository: PermissionRepository
    init(repository: PermissionRepository) {
        self.repository = repository
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        repository.requestCameraPermission(completion: completion)
    }
    
    func checkPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void) {
        repository.requestPhotoLibraryAddOnlyPermission(completion: completion)
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        repository.requestPhotoLibraryPermission(completion: completion)
    }

}
