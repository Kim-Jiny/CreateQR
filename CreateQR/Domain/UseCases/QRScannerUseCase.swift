//
//  QRScannerUseCase.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import AVFoundation

protocol QRScannerUseCase {
    func checkCameraPermission(completion: @escaping (Bool) -> Void)
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void)
    func stopScanning()
}

class QRScannerUseCaseImpl: QRScannerUseCase {
    private let repository: QRScannerRepository

    init(repository: QRScannerRepository) {
        self.repository = repository
    }

    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        repository.requestCameraPermission(completion: completion)
    }

    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void) {
        repository.startScanning(previewLayer: previewLayer, completion: completion)
    }
    
    func stopScanning() {
        repository.stopScanning()  // 스캔 세션 중단
    }
}
