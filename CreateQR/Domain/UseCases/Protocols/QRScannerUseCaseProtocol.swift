//
//  QRScannerUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation
import AVFoundation

protocol QRScannerUseCaseProtocol {
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void)
    func stopScanning()
}
