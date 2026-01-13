//
//  QRScannerRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation
import AVFoundation

protocol QRScannerRepositoryProtocol {
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void)
    func stopScanning()
}
