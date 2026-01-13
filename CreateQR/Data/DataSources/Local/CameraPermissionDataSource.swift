//
//  CameraPermissionDataSource.swift
//  CreateQR
//
//  Clean Architecture - Data Layer DataSource
//

import Foundation
import AVFoundation

final class CameraPermissionDataSource {

    func requestPermissionCamera(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }
}
