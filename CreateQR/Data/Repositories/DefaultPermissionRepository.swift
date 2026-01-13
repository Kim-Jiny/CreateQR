//
//  DefaultPermissionRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation

final class DefaultPermissionRepository: NSObject, PermissionRepository {

    private let photoLibraryPermissionDataSource: PhotoLibraryPermissionDataSource
    private let cameraPermissionDataSource: CameraPermissionDataSource

    init(
        cameraPermissionDataSource: CameraPermissionDataSource,
        photoLibraryPermissionDataSource: PhotoLibraryPermissionDataSource
    ) {
        self.cameraPermissionDataSource = cameraPermissionDataSource
        self.photoLibraryPermissionDataSource = photoLibraryPermissionDataSource
    }

    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        cameraPermissionDataSource.requestPermissionCamera(completion: completion)
    }

    func requestPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void) {
        photoLibraryPermissionDataSource.requestPermissionAndSaveImage(completion: completion)
    }

    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        photoLibraryPermissionDataSource.requestPermissionPhotoLibrary(completion: completion)
    }
}
