//
//  PhotoLibraryPermissionDataSource.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import Photos

class PhotoLibraryPermissionDataSource {
    // 사진 라이브러리에 저장 권한 요청 및 저장 기능
    func requestPermissionAndSaveImage(completion: @escaping (Bool) -> Void) {
       let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly) // iOS 14 이상에서 .addOnly 사용 가능
       
       switch authorizationStatus {
       case .authorized, .limited:
           // 이미 권한이 허용된 경우
           completion(true)
       case .notDetermined:
           // 권한이 결정되지 않은 경우, 권한 요청
           PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
               completion(newStatus == .authorized)
           }
           
       case .denied, .restricted:
           // 권한이 거부되었거나 제한된 경우
           completion(false)
           
       @unknown default:
           completion(false)
       }
    }
    
    // 사진 라이브러리 권한 요청
    func requestPermissionPhotoLibrary(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            // 이미 권한이 허용된 경우
            completion(true)
            
        case .notDetermined:
            // 권한이 결정되지 않은 경우, 권한 요청
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized)
            }
            
        case .denied, .restricted, .limited:
            // 권한이 거부되었거나 제한된 경우
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
}
