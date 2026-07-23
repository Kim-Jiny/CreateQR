//
//  CameraPermissionDataSource.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import AVFoundation

class CameraPermissionDataSource {
    
    // 카메라 권한 요청
    func requestPermissionCamera(completion: @escaping (Bool) -> Void) {
        // 권한 상태 확인
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            // 이미 권한이 허용된 경우
            completion(true)

        case .notDetermined:
            // 권한이 결정되지 않은 경우, 권한 요청
            // requestAccess 콜백은 임의의 백그라운드 스레드에서 호출되므로 메인 스레드로 전환.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }

        case .denied, .restricted:
            // 권한이 거부되었거나 제한된 경우
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
