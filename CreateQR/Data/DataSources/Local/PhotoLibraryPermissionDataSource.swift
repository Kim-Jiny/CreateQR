//
//  PhotoLibraryPermissionDataSource.swift
//  CreateQR
//
//  Clean Architecture - Data Layer DataSource
//

import Foundation
import Photos

final class PhotoLibraryPermissionDataSource {

    func requestPermissionAndSaveImage(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch authorizationStatus {
        case .authorized, .limited:
            completion(true)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    func requestPermissionPhotoLibrary(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch authorizationStatus {
        case .authorized, .limited:
            completion(true)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }
}
