//
//  PermissionRepository.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation

protocol PermissionRepository {
    func requestCameraPermission(completion: @escaping (Bool) -> Void)
    func requestPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void)
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void)
}

class PermissionRepositoryImpl: NSObject, PermissionRepository {
    private let photoLibraryPermissionDataSource: PhotoLibraryPermissionDataSource
    private let cameraPermissionDataSource: CameraPermissionDataSource
    private var completion: ((String) -> Void)?

    init(cameraPermissionDataSource: CameraPermissionDataSource, photoLibraryPermissionDataSource: PhotoLibraryPermissionDataSource) {
        self.cameraPermissionDataSource = cameraPermissionDataSource
        self.photoLibraryPermissionDataSource = photoLibraryPermissionDataSource
    }
    // 카메라 권한 요청
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        cameraPermissionDataSource.requestPermissionCamera(completion: completion)
    }
    // 사진 추가 권한 요청
    func requestPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void) {
        photoLibraryPermissionDataSource.requestPermissionAndSaveImage(completion: completion)
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        photoLibraryPermissionDataSource.requestPermissionPhotoLibrary(completion: completion)
    }
}
